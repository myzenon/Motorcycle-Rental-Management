-- phpMyAdmin SQL Dump
-- version 4.5.1
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Generation Time: Dec 15, 2015 at 05:31 PM
-- Server version: 10.1.9-MariaDB
-- PHP Version: 5.6.15

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `motorcycle-rental`
--
CREATE DATABASE IF NOT EXISTS `motorcycle-rental` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `motorcycle-rental`;

DELIMITER $$
--
-- Procedures
--
DROP PROCEDURE IF EXISTS `delete_motorcycle`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_motorcycle` (IN `id` INT)  MODIFIES SQL DATA
BEGIN
	DECLARE brand_id INT;
	DECLARE amount INT;
    SELECT motorcycle.brand_id INTO brand_id FROM motorcycle WHERE motorcycle.id = id;
	DELETE FROM motorcycle WHERE motorcycle.id = id;
    DELETE FROM rental WHERE rental.motorcycle_id = id;
    DELETE FROM repair WHERE repair.motorcycle_id = id;
    SELECT COUNT(motorcycle.brand_id) INTO amount FROM motorcycle WHERE motorcycle.brand_id = brand_id;
    IF amount = 0 THEN
    	DELETE FROM brand WHERE brand.id = brand_id;
    END IF;
END$$

DROP PROCEDURE IF EXISTS `edit_motorcycle`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `edit_motorcycle` (IN `id` INT, IN `brand_id` INT, IN `brand_new` VARCHAR(100) CHARSET utf8, IN `model` VARCHAR(100) CHARSET utf8, IN `plate_number` VARCHAR(100) CHARSET utf8, IN `cost` INT, IN `collateral` INT, IN `ppd` INT, IN `ppm` INT)  BEGIN
    IF brand_id = 0 THEN
		INSERT INTO brand (brand.name) VALUES (brand_new);
        SELECT brand.id INTO brand_id FROM brand ORDER BY brand.id DESC LIMIT 1;
    END IF;
    UPDATE motorcycle SET motorcycle.brand_id = brand_id, motorcycle.model = model, motorcycle.plate_number = plate_number, motorcycle.cost = cost, motorcycle.collateral = collateral, motorcycle.price_per_day = ppd, motorcycle.price_per_month = ppm WHERE motorcycle.id = id;
END$$

DROP PROCEDURE IF EXISTS `insert_motorcycle`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_motorcycle` (IN `brand_id` INT, IN `brand_new` VARCHAR(100) CHARSET utf8, IN `model` VARCHAR(100) CHARSET utf8, IN `plate_number` VARCHAR(100) CHARSET utf8, IN `cost` INT, IN `collateral` INT, IN `ppd` INT, IN `ppm` INT)  BEGIN
    IF brand_id = 0 THEN
		INSERT INTO brand (name) VALUES (brand_new);
        SELECT brand.id INTO brand_id FROM brand ORDER BY brand.id DESC LIMIT 1;
    END IF;
    INSERT INTO motorcycle (motorcycle.brand_id, motorcycle.model, motorcycle.plate_number, motorcycle.cost, motorcycle.collateral, motorcycle.price_per_day, motorcycle.price_per_month, motorcycle.status) VALUES(brand_id, model, plate_number, cost, collateral, ppd, ppm, "avaliable");
END$$

DROP PROCEDURE IF EXISTS `insert_rental`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_rental` (IN `motorcycle_id` INT, IN `firstname` VARCHAR(150) CHARSET utf8, IN `lastname` VARCHAR(150) CHARSET utf8, IN `cznum` VARCHAR(100) CHARSET utf8, IN `dlnum` VARCHAR(100) CHARSET utf8, IN `phone` VARCHAR(15) CHARSET utf8, IN `type` ENUM('day','month') CHARSET utf8, IN `amount` INT, IN `price` INT, IN `collateral` INT, IN `dre` DATE)  BEGIN
	DECLARE rental_id INT;
    INSERT INTO rental (rental.motorcycle_id, rental.type, rental.amount, rental.price, rental.collateral, rental.date_rent, rental.date_return_expect) VALUES (motorcycle_id, type, amount, price, collateral, NOW(), dre);
    SELECT rental.id INTO rental_id FROM rental ORDER BY rental.id DESC LIMIT 1;
  	INSERT INTO customer VALUES(rental_id, firstname, lastname, cznum, dlnum, phone);
    UPDATE motorcycle SET motorcycle.status = "rented" WHERE motorcycle.id = motorcycle_id;
END$$

DROP PROCEDURE IF EXISTS `return_rental`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `return_rental` (IN `id` INT, IN `nrepair` BOOLEAN, IN `fine` INT)  MODIFIES SQL DATA
BEGIN
	DECLARE motorcycle_id INT;
	UPDATE rental SET rental.nrepair = nrepair, rental.fine = fine, rental.date_return_returned = NOW() WHERE rental.id = id;
    SELECT rental.motorcycle_id INTO motorcycle_id FROM rental WHERE rental.id = id;
    IF nrepair THEN
    	UPDATE motorcycle SET motorcycle.status = 'nrepair' WHERE motorcycle.id = motorcycle_id;
        INSERT INTO repair (repair.motorcycle_id) VALUES(motorcycle_id);
    ELSE
    	UPDATE motorcycle SET motorcycle.status = 'avaliable' WHERE motorcycle.id = motorcycle_id;
    END IF;
END$$

DROP PROCEDURE IF EXISTS `update_repair`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_repair` (IN `id` INT, IN `problem` TEXT CHARSET utf8, IN `cause` TEXT CHARSET utf8, IN `cost` INT)  MODIFIES SQL DATA
BEGIN
    DECLARE motorcycle_id INT;
    IF (cause IS NULL) = 1 AND (cost IS NULL) = 1 THEN
        UPDATE repair SET repair.problem = problem, repair.date_send = NOW() WHERE repair.id = id;
        SELECT repair.motorcycle_id INTO motorcycle_id FROM repair WHERE repair.id = id;
        UPDATE motorcycle SET motorcycle.status = 'wrepair' WHERE motorcycle.id = motorcycle_id;
    ELSE
        UPDATE repair SET repair.cost = cost, repair.cause = cause, repair.date_return = NOW() WHERE repair.id = id;
        SELECT repair.motorcycle_id INTO motorcycle_id FROM repair WHERE repair.id = id;
        UPDATE motorcycle SET motorcycle.status = 'avaliable' WHERE motorcycle.id = motorcycle_id;
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `brand`
--

DROP TABLE IF EXISTS `brand`;
CREATE TABLE `brand` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `brand`
--

INSERT INTO `brand` (`id`, `name`) VALUES
(1, 'Suzuki'),
(2, 'Honda'),
(3, 'Kawasaki'),
(4, 'Yamaha');

-- --------------------------------------------------------

--
-- Table structure for table `customer`
--

DROP TABLE IF EXISTS `customer`;
CREATE TABLE `customer` (
  `rental_id` int(11) NOT NULL,
  `firstname` varchar(150) CHARACTER SET latin1 NOT NULL,
  `lastname` varchar(150) CHARACTER SET latin1 NOT NULL,
  `cznum` varchar(100) CHARACTER SET latin1 NOT NULL,
  `dlnum` varchar(100) CHARACTER SET latin1 NOT NULL,
  `phone` varchar(15) CHARACTER SET latin1 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `customer`
--

INSERT INTO `customer` (`rental_id`, `firstname`, `lastname`, `cznum`, `dlnum`, `phone`) VALUES
(1, 'John', 'Smith', '0340296446GBR79092555M141106506', 'DB 09875-25', '0904872782'),
(2, 'Saijai', 'Patthadee', '1702488045286', '95230751', '0854875415'),
(3, 'Somsee', 'Meekin', '8279994993554', '06886825', '0815475245'),
(4, 'Samas', 'Bunwan', '1914851732392', '43633269', '0954857848'),
(5, 'Seungeun', 'Ja', 'EO7335386', 'DL464258', '0828784575'),
(6, 'Somchai', 'Angdee', '1346590181964', '35039004', '0815213454'),
(7, 'Jirat', 'Sandee', '2202559153071', '88054965', '0812482542'),
(8, 'Wisead', 'Damrong', '5633871407963', '99504542', '0912424884'),
(9, 'Kanya', 'Intone', '5240109185748', '70722960', '0841524547'),
(10, 'Somchai', 'Shosuk', '8019786888931', '47684685', '0864502114');

-- --------------------------------------------------------

--
-- Table structure for table `motorcycle`
--

DROP TABLE IF EXISTS `motorcycle`;
CREATE TABLE `motorcycle` (
  `id` int(11) NOT NULL,
  `brand_id` int(11) NOT NULL,
  `model` varchar(100) NOT NULL,
  `plate_number` varchar(100) NOT NULL,
  `cost` int(11) NOT NULL,
  `collateral` int(11) NOT NULL,
  `price_per_day` int(11) DEFAULT NULL,
  `price_per_month` int(11) DEFAULT NULL,
  `status` enum('avaliable','rented','nrepair','wrepair') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `motorcycle`
--

INSERT INTO `motorcycle` (`id`, `brand_id`, `model`, `plate_number`, `cost`, `collateral`, `price_per_day`, `price_per_month`, `status`) VALUES
(1, 1, 'Shooter 115', 'กษบ 44', 40000, 0, 200, NULL, 'rented'),
(2, 2, 'Forza 300', 'วจท 508', 80000, 5000, 1000, NULL, 'rented'),
(3, 3, 'Z250', 'รกช 187', 75000, 4500, 1000, NULL, 'avaliable'),
(4, 2, 'Click 125', 'วยก 787', 450000, 0, 300, 8500, 'avaliable'),
(5, 1, 'Let''s 115', 'กลค 810', 37000, 100, 250, 7000, 'avaliable'),
(6, 2, 'Zommer X', 'กขก 177', 50000, 0, 350, 10000, 'rented'),
(7, 3, 'KSR 125', 'อมร 256', 60000, 3000, 400, NULL, 'rented'),
(8, 2, 'CB500X', 'ษฉธ 853', 90000, 5500, 1300, NULL, 'avaliable'),
(9, 2, 'MSX 125', 'บษจ 111', 65000, 3000, 500, 13000, 'rented'),
(10, 2, 'PCX 150', '2กว 787', 120000, 4000, 600, NULL, 'rented'),
(11, 3, 'Ninja 300', '8กข 765', 150000, 6000, 1100, NULL, 'avaliable'),
(12, 1, 'Raider 150', 'บนย 468', 47000, 500, NULL, 10000, 'rented'),
(13, 1, 'VanVan 125', 'อพป 449', 70000, 4000, 700, NULL, 'wrepair'),
(14, 4, 'Tricity 125', 'ฬอต 837', 80000, 4200, 400, NULL, 'avaliable'),
(15, 2, 'CBF300', 'อขล 778', 85000, 4800, 1200, NULL, 'avaliable'),
(16, 4, 'TTX 115', 'ฬคษ 123', 46000, 0, 250, 7300, 'avaliable'),
(17, 1, 'Burgman 200', 'ญบข 204', 100000, 5000, 1000, NULL, 'nrepair'),
(18, 4, 'Fiore 115', 'พทท 892', 38000, 0, 250, 7000, 'avaliable'),
(19, 4, 'Mio 125', 'กขค 887', 42000, 1000, NULL, 7500, 'avaliable'),
(20, 1, 'Hayate 125', 'ภทธ 870', 45500, 0, 250, NULL, 'avaliable'),
(21, 1, 'The Nex 113', 'วกว 652', 41000, 500, NULL, 7400, 'avaliable');

-- --------------------------------------------------------

--
-- Stand-in structure for view `motorcycle_list`
--
DROP VIEW IF EXISTS `motorcycle_list`;
CREATE TABLE `motorcycle_list` (
`id` int(11)
,`brand_name` varchar(100)
,`model` varchar(100)
,`plate_number` varchar(100)
,`status` enum('avaliable','rented','nrepair','wrepair')
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `motorcycle_view`
--
DROP VIEW IF EXISTS `motorcycle_view`;
CREATE TABLE `motorcycle_view` (
`id` int(11)
,`brand_id` int(11)
,`brand_name` varchar(100)
,`model` varchar(100)
,`plate_number` varchar(100)
,`cost` int(11)
,`collateral` int(11)
,`price_per_day` int(11)
,`price_per_month` int(11)
,`status` enum('avaliable','rented','nrepair','wrepair')
);

-- --------------------------------------------------------

--
-- Table structure for table `rental`
--

DROP TABLE IF EXISTS `rental`;
CREATE TABLE `rental` (
  `id` int(11) NOT NULL,
  `motorcycle_id` int(11) NOT NULL,
  `type` enum('day','month') NOT NULL,
  `amount` int(11) NOT NULL,
  `price` int(11) NOT NULL,
  `collateral` int(11) NOT NULL,
  `date_rent` date NOT NULL,
  `date_return_expect` date NOT NULL,
  `date_return_returned` date DEFAULT NULL,
  `nrepair` tinyint(1) NOT NULL,
  `fine` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `rental`
--

INSERT INTO `rental` (`id`, `motorcycle_id`, `type`, `amount`, `price`, `collateral`, `date_rent`, `date_return_expect`, `date_return_returned`, `nrepair`, `fine`) VALUES
(1, 10, 'day', 5, 600, 4000, '2015-12-08', '2015-12-13', NULL, 0, NULL),
(2, 13, 'day', 5, 700, 4000, '2015-11-15', '2015-11-20', '2015-11-20', 1, 1700),
(3, 7, 'day', 3, 400, 3000, '2015-12-07', '2015-12-10', NULL, 0, NULL),
(4, 16, 'month', 1, 7300, 0, '2015-11-15', '2015-12-15', '2015-12-12', 1, 1500),
(5, 2, 'day', 5, 1000, 5000, '2015-12-15', '2015-12-20', NULL, 0, NULL),
(6, 17, 'day', 4, 1000, 5000, '2015-11-15', '2015-11-19', '2015-11-21', 1, 1200),
(7, 12, 'month', 1, 10000, 500, '2015-12-15', '2016-01-15', NULL, 0, NULL),
(8, 6, 'day', 5, 350, 0, '2015-12-11', '2015-12-16', NULL, 0, NULL),
(9, 1, 'day', 2, 200, 0, '2015-12-14', '2015-12-16', NULL, 0, NULL),
(10, 9, 'day', 4, 500, 3000, '2015-12-15', '2015-12-19', NULL, 0, NULL);

-- --------------------------------------------------------

--
-- Stand-in structure for view `rental_list`
--
DROP VIEW IF EXISTS `rental_list`;
CREATE TABLE `rental_list` (
`id` int(11)
,`motorcycle_id` int(11)
,`brand_name` varchar(100)
,`model` varchar(100)
,`plate_number` varchar(100)
,`status` enum('avaliable','rented','nrepair','wrepair')
,`firstname` varchar(150)
,`lastname` varchar(150)
,`date_rent` date
,`date_return_expect` date
,`date_return_returned` date
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `rental_view`
--
DROP VIEW IF EXISTS `rental_view`;
CREATE TABLE `rental_view` (
`id` int(11)
,`brand_name` varchar(100)
,`model` varchar(100)
,`plate_number` varchar(100)
,`status` enum('avaliable','rented','nrepair','wrepair')
,`firstname` varchar(150)
,`lastname` varchar(150)
,`cznum` varchar(100)
,`dlnum` varchar(100)
,`phone` varchar(15)
,`type` enum('day','month')
,`amount` int(11)
,`price` int(11)
,`collateral` int(11)
,`date_rent` date
,`date_return_expect` date
,`date_return_returned` date
,`nrepair` tinyint(1)
,`fine` int(11)
);

-- --------------------------------------------------------

--
-- Table structure for table `repair`
--

DROP TABLE IF EXISTS `repair`;
CREATE TABLE `repair` (
  `id` int(11) NOT NULL,
  `motorcycle_id` int(11) NOT NULL,
  `problem` text,
  `cause` text,
  `cost` int(11) DEFAULT NULL,
  `date_send` date DEFAULT NULL,
  `date_return` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `repair`
--

INSERT INTO `repair` (`id`, `motorcycle_id`, `problem`, `cause`, `cost`, `date_send`, `date_return`) VALUES
(1, 17, NULL, NULL, NULL, NULL, NULL),
(2, 13, 'Handbrake Broken', NULL, NULL, '2015-12-02', NULL),
(3, 16, 'Handbrake Broken', 'Handbrake line broken', 1000, '2015-12-13', '2015-12-15');

-- --------------------------------------------------------

--
-- Stand-in structure for view `repair_view`
--
DROP VIEW IF EXISTS `repair_view`;
CREATE TABLE `repair_view` (
`id` int(11)
,`motorcycle_id` int(11)
,`brand_name` varchar(100)
,`model` varchar(100)
,`plate_number` varchar(100)
,`status` enum('avaliable','rented','nrepair','wrepair')
,`problem` text
,`cause` text
,`cost` int(11)
,`date_send` varchar(72)
,`date_return` varchar(72)
);

-- --------------------------------------------------------

--
-- Structure for view `motorcycle_list`
--
DROP TABLE IF EXISTS `motorcycle_list`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `motorcycle_list`  AS  select `motorcycle`.`id` AS `id`,`brand`.`name` AS `brand_name`,`motorcycle`.`model` AS `model`,`motorcycle`.`plate_number` AS `plate_number`,`motorcycle`.`status` AS `status` from (`motorcycle` join `brand`) where (`motorcycle`.`brand_id` = `brand`.`id`) order by `brand`.`id`,`motorcycle`.`id` desc ;

-- --------------------------------------------------------

--
-- Structure for view `motorcycle_view`
--
DROP TABLE IF EXISTS `motorcycle_view`;

CREATE ALGORITHM=MERGE DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `motorcycle_view`  AS  select `motorcycle`.`id` AS `id`,`motorcycle`.`brand_id` AS `brand_id`,`brand`.`name` AS `brand_name`,`motorcycle`.`model` AS `model`,`motorcycle`.`plate_number` AS `plate_number`,`motorcycle`.`cost` AS `cost`,`motorcycle`.`collateral` AS `collateral`,`motorcycle`.`price_per_day` AS `price_per_day`,`motorcycle`.`price_per_month` AS `price_per_month`,`motorcycle`.`status` AS `status` from (`brand` join `motorcycle`) where (`brand`.`id` = `motorcycle`.`brand_id`) ;

-- --------------------------------------------------------

--
-- Structure for view `rental_list`
--
DROP TABLE IF EXISTS `rental_list`;

CREATE ALGORITHM=MERGE DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `rental_list`  AS  select `rental`.`id` AS `id`,`motorcycle`.`id` AS `motorcycle_id`,`brand`.`name` AS `brand_name`,`motorcycle`.`model` AS `model`,`motorcycle`.`plate_number` AS `plate_number`,`motorcycle`.`status` AS `status`,`customer`.`firstname` AS `firstname`,`customer`.`lastname` AS `lastname`,`rental`.`date_rent` AS `date_rent`,`rental`.`date_return_expect` AS `date_return_expect`,`rental`.`date_return_returned` AS `date_return_returned` from (((`motorcycle` join `brand`) join `rental`) join `customer`) where ((`rental`.`motorcycle_id` = `motorcycle`.`id`) and (`motorcycle`.`brand_id` = `brand`.`id`) and (`rental`.`id` = `customer`.`rental_id`)) order by `rental`.`date_rent` desc,`rental`.`id` desc ;

-- --------------------------------------------------------

--
-- Structure for view `rental_view`
--
DROP TABLE IF EXISTS `rental_view`;

CREATE ALGORITHM=MERGE DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `rental_view`  AS  select `rental`.`id` AS `id`,`brand`.`name` AS `brand_name`,`motorcycle`.`model` AS `model`,`motorcycle`.`plate_number` AS `plate_number`,`motorcycle`.`status` AS `status`,`customer`.`firstname` AS `firstname`,`customer`.`lastname` AS `lastname`,`customer`.`cznum` AS `cznum`,`customer`.`dlnum` AS `dlnum`,`customer`.`phone` AS `phone`,`rental`.`type` AS `type`,`rental`.`amount` AS `amount`,`rental`.`price` AS `price`,`rental`.`collateral` AS `collateral`,`rental`.`date_rent` AS `date_rent`,`rental`.`date_return_expect` AS `date_return_expect`,`rental`.`date_return_returned` AS `date_return_returned`,`rental`.`nrepair` AS `nrepair`,`rental`.`fine` AS `fine` from (((`rental` join `customer`) join `brand`) join `motorcycle`) where ((`rental`.`motorcycle_id` = `motorcycle`.`id`) and (`motorcycle`.`brand_id` = `brand`.`id`) and (`rental`.`id` = `customer`.`rental_id`)) ;

-- --------------------------------------------------------

--
-- Structure for view `repair_view`
--
DROP TABLE IF EXISTS `repair_view`;

CREATE ALGORITHM=MERGE DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `repair_view`  AS  select `repair`.`id` AS `id`,`motorcycle`.`id` AS `motorcycle_id`,`brand`.`name` AS `brand_name`,`motorcycle`.`model` AS `model`,`motorcycle`.`plate_number` AS `plate_number`,`motorcycle`.`status` AS `status`,`repair`.`problem` AS `problem`,`repair`.`cause` AS `cause`,`repair`.`cost` AS `cost`,date_format(`repair`.`date_send`,'%d %M %Y') AS `date_send`,date_format(`repair`.`date_return`,'%d %M %Y') AS `date_return` from ((`repair` join `motorcycle`) join `brand`) where ((`repair`.`motorcycle_id` = `motorcycle`.`id`) and (`motorcycle`.`brand_id` = `brand`.`id`)) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `brand`
--
ALTER TABLE `brand`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`rental_id`);

--
-- Indexes for table `motorcycle`
--
ALTER TABLE `motorcycle`
  ADD PRIMARY KEY (`id`),
  ADD KEY `brand_id` (`brand_id`);

--
-- Indexes for table `rental`
--
ALTER TABLE `rental`
  ADD PRIMARY KEY (`id`),
  ADD KEY `motorcycle_id` (`motorcycle_id`);

--
-- Indexes for table `repair`
--
ALTER TABLE `repair`
  ADD PRIMARY KEY (`id`),
  ADD KEY `motorcycle_id` (`motorcycle_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `brand`
--
ALTER TABLE `brand`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT for table `motorcycle`
--
ALTER TABLE `motorcycle`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;
--
-- AUTO_INCREMENT for table `rental`
--
ALTER TABLE `rental`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT for table `repair`
--
ALTER TABLE `repair`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
