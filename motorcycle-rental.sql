-- phpMyAdmin SQL Dump
-- version 4.4.14
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Dec 07, 2015 at 09:26 AM
-- Server version: 5.6.26
-- PHP Version: 5.6.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `motorcycle-rental`
--
CREATE DATABASE IF NOT EXISTS `motorcycle-rental` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `motorcycle-rental`;

DELIMITER $$
--
-- Procedures
--
DROP PROCEDURE IF EXISTS `delete_motorcycle`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_motorcycle`(IN `id` INT)
    MODIFIES SQL DATA
BEGIN
	DECLARE brand_id INT;
	DECLARE amount INT;
    SELECT motorcycle.brand_id INTO brand_id FROM motorcycle WHERE motorcycle.id = id;
	DELETE FROM motorcycle WHERE motorcycle.id = id;
    SELECT COUNT(motorcycle.brand_id) INTO amount FROM motorcycle WHERE motorcycle.brand_id = brand_id;
    IF amount = 0 THEN
    	DELETE FROM brand WHERE brand.id = brand_id;
    END IF;
END$$

DROP PROCEDURE IF EXISTS `edit_motorcycle`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `edit_motorcycle`(IN `id` INT, IN `brand_id` INT, IN `brand_new` VARCHAR(100) CHARSET utf8, IN `model` VARCHAR(100) CHARSET utf8, IN `plate_number` VARCHAR(100) CHARSET utf8, IN `cost` INT, IN `collateral` INT, IN `ppd` INT, IN `ppm` INT)
BEGIN
    IF brand_id = 0 THEN
		INSERT INTO brand (brand.name) VALUES (brand_new);
        SELECT brand.id INTO brand_id FROM brand ORDER BY brand.id DESC LIMIT 1;
    END IF;
    UPDATE motorcycle SET motorcycle.brand_id = brand_id, motorcycle.model = model, motorcycle.plate_number = plate_number, motorcycle.cost = cost, motorcycle.collateral = collateral, motorcycle.price_per_day = ppd, motorcycle.price_per_month = ppm WHERE motorcycle.id = id;
END$$

DROP PROCEDURE IF EXISTS `insert_motorcycle`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_motorcycle`(IN `brand_id` INT, IN `brand_new` VARCHAR(100) CHARSET utf8, IN `model` VARCHAR(100) CHARSET utf8, IN `plate_number` VARCHAR(100) CHARSET utf8, IN `cost` INT, IN `collateral` INT, IN `ppd` INT, IN `ppm` INT)
BEGIN
    IF brand_id = 0 THEN
		INSERT INTO brand (name) VALUES (brand_new);
        SELECT brand.id INTO brand_id FROM brand ORDER BY brand.id DESC LIMIT 1;
    END IF;
    INSERT INTO motorcycle (motorcycle.brand_id, motorcycle.model, motorcycle.plate_number, motorcycle.cost, motorcycle.collateral, motorcycle.price_per_day, motorcycle.price_per_month, motorcycle.status) VALUES(brand_id, model, plate_number, cost, collateral, ppd, ppm, "avaliable");
END$$

DROP PROCEDURE IF EXISTS `insert_rental`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_rental`(IN `motorcycle_id` INT, IN `firstname` VARCHAR(150) CHARSET utf8, IN `lastname` VARCHAR(150) CHARSET utf8, IN `cznum` VARCHAR(100) CHARSET utf8, IN `dlnum` VARCHAR(100) CHARSET utf8, IN `phone` VARCHAR(15) CHARSET utf8, IN `type` ENUM('day','month'), IN `amount` INT, IN `dre` DATE)
BEGIN
INSERT INTO rental (rental.motorcycle_id, rental.firstname, rental.lastname, rental.cznum, rental.dlnum, rental.phone, rental.type, rental.amount, rental.date_rent, rental.date_return_expect) VALUES (motorcycle_id, firstname, lastname, cznum, dlnum, phone, type, amount, NOW(), dre);
UPDATE motorcycle SET motorcycle.status = "rented" WHERE motorcycle.id = motorcycle_id;
END$$

DROP PROCEDURE IF EXISTS `return_rental`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `return_rental`(IN `id` INT, IN `nrepair` BOOLEAN, IN `fine` INT)
    MODIFIES SQL DATA
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_repair`(IN `id` INT, IN `problem` TEXT CHARSET utf8, IN `cause` TEXT CHARSET utf8, IN `cost` INT)
    MODIFIES SQL DATA
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
CREATE TABLE IF NOT EXISTS `brand` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `brand`
--

INSERT INTO `brand` (`id`, `name`) VALUES
(1, 'Yamaha'),
(2, 'Test'),
(3, 'Suzuki'),
(4, 'YUO'),
(5, 'NewR'),
(7, 'Zenon'),
(8, 'BBBBB3'),
(9, 'Luffy'),
(10, 'Puffy'),
(11, 'Tu'),
(12, '77878');

-- --------------------------------------------------------

--
-- Table structure for table `motorcycle`
--

DROP TABLE IF EXISTS `motorcycle`;
CREATE TABLE IF NOT EXISTS `motorcycle` (
  `id` int(11) NOT NULL,
  `brand_id` int(11) NOT NULL,
  `model` varchar(100) NOT NULL,
  `plate_number` varchar(100) NOT NULL,
  `cost` int(11) NOT NULL,
  `collateral` int(11) NOT NULL,
  `price_per_day` int(11) DEFAULT NULL,
  `price_per_month` int(11) DEFAULT NULL,
  `status` enum('avaliable','rented','nrepair','wrepair') NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `motorcycle`
--

INSERT INTO `motorcycle` (`id`, `brand_id`, `model`, `plate_number`, `cost`, `collateral`, `price_per_day`, `price_per_month`, `status`) VALUES
(28, 28, 'FX 1', '0 กง', 34534, 3453454, NULL, 345345, 'avaliable'),
(29, 4, '34534', '345345', 43534, 34534, NULL, NULL, 'avaliable'),
(31, 2, '435345', '545345', 4534, 4345345, NULL, NULL, 'avaliable'),
(32, 1, '34534', '4353', 45345, 34534, NULL, 345345, 'nrepair'),
(36, 7, '322', '345345', 34, 54345, 10, 200, 'rented'),
(40, 5, '345345', '345345345', 45345345, 34534534, 45345, 5345345, 'rented'),
(41, 2, '435345', '4545', 45345, 4534534, 5435345, NULL, 'rented');

-- --------------------------------------------------------

--
-- Stand-in structure for view `motorcycle_list`
--
DROP VIEW IF EXISTS `motorcycle_list`;
CREATE TABLE IF NOT EXISTS `motorcycle_list` (
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
CREATE TABLE IF NOT EXISTS `motorcycle_view` (
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
CREATE TABLE IF NOT EXISTS `rental` (
  `id` int(11) NOT NULL,
  `motorcycle_id` int(11) NOT NULL,
  `firstname` varchar(150) NOT NULL,
  `lastname` varchar(150) NOT NULL,
  `cznum` varchar(100) NOT NULL,
  `dlnum` varchar(100) NOT NULL,
  `phone` varchar(15) NOT NULL,
  `type` enum('day','month') NOT NULL,
  `amount` int(11) NOT NULL,
  `date_rent` date NOT NULL,
  `date_return_expect` date NOT NULL,
  `date_return_returned` date DEFAULT NULL,
  `nrepair` tinyint(1) NOT NULL,
  `fine` int(11) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `rental`
--

INSERT INTO `rental` (`id`, `motorcycle_id`, `firstname`, `lastname`, `cznum`, `dlnum`, `phone`, `type`, `amount`, `date_rent`, `date_return_expect`, `date_return_returned`, `nrepair`, `fine`) VALUES
(1, 41, 'Test', 'Last', '43534534534534534', '345345345345', '1246', 'day', 3, '2015-12-01', '2015-12-04', '2015-12-07', 0, 1000),
(2, 41, '435345', '324234', 'dr423', '534534534', '01057', 'day', 31, '2015-12-06', '2015-12-07', '2015-12-07', 0, 1200),
(3, 41, 'erewr', 'ewrewr', '543534', '24', '23423', 'day', 3, '2015-12-07', '2015-11-25', '2015-12-07', 0, 1000),
(4, 41, 'Name', 'Last', '777877787', '2578643489', '1121', 'day', 10, '2015-12-07', '2015-12-08', '2015-12-07', 0, 1000),
(5, 41, '35345', '435345', '435345', '345345', '435345', 'day', 32, '2015-11-27', '2015-12-02', '2015-12-07', 0, 100),
(6, 32, 'dsfdsf', 'dsfdsf', '54645645645645', '465645645', '4353454', 'month', 2, '2015-12-07', '2016-02-07', '2015-12-07', 1, 5000),
(7, 41, '353454', '5345345', '4534534', '53453453', '4564564565', 'day', 3, '2015-12-07', '2015-12-10', '2015-12-07', 0, 1000000000),
(8, 41, '345', '654645', '5645', '5345', '4564564', 'day', 3, '2015-12-07', '2015-12-10', '2015-12-07', 0, 4534534),
(9, 41, '453', '5345345', '43534', '435', '435', 'day', 1, '2015-12-07', '2015-12-08', '2015-12-07', 0, NULL),
(10, 41, '34534', '345345', '345345', '345345', '345345345', 'day', 23, '2015-12-07', '2015-12-30', NULL, 0, NULL),
(11, 36, '34534', '345345', '345345', '43534', '345', 'month', 1, '2015-12-07', '2016-01-07', NULL, 0, NULL);

-- --------------------------------------------------------

--
-- Stand-in structure for view `rental_list`
--
DROP VIEW IF EXISTS `rental_list`;
CREATE TABLE IF NOT EXISTS `rental_list` (
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
CREATE TABLE IF NOT EXISTS `rental_view` (
`id` int(11)
,`brand_name` varchar(100)
,`model` varchar(100)
,`plate_number` varchar(100)
,`collateral` int(11)
,`price_per_day` int(11)
,`price_per_month` int(11)
,`status` enum('avaliable','rented','nrepair','wrepair')
,`firstname` varchar(150)
,`lastname` varchar(150)
,`cznum` varchar(100)
,`dlnum` varchar(100)
,`phone` varchar(15)
,`type` enum('day','month')
,`amount` int(11)
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
CREATE TABLE IF NOT EXISTS `repair` (
  `id` int(11) NOT NULL,
  `motorcycle_id` int(11) NOT NULL,
  `problem` text,
  `cause` text,
  `cost` int(11) DEFAULT NULL,
  `date_send` date DEFAULT NULL,
  `date_return` date DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `repair`
--

INSERT INTO `repair` (`id`, `motorcycle_id`, `problem`, `cause`, `cost`, `date_send`, `date_return`) VALUES
(1, 36, '45345', '5345345', 34534, '2015-12-06', '2015-12-06'),
(3, 32, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Stand-in structure for view `repair_view`
--
DROP VIEW IF EXISTS `repair_view`;
CREATE TABLE IF NOT EXISTS `repair_view` (
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

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `motorcycle_list` AS select `motorcycle`.`id` AS `id`,`brand`.`name` AS `brand_name`,`motorcycle`.`model` AS `model`,`motorcycle`.`plate_number` AS `plate_number`,`motorcycle`.`status` AS `status` from (`motorcycle` join `brand`) where (`motorcycle`.`brand_id` = `brand`.`id`) order by `brand`.`id`,`motorcycle`.`id` desc;

-- --------------------------------------------------------

--
-- Structure for view `motorcycle_view`
--
DROP TABLE IF EXISTS `motorcycle_view`;

CREATE ALGORITHM=MERGE DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `motorcycle_view` AS select `motorcycle`.`id` AS `id`,`motorcycle`.`brand_id` AS `brand_id`,`brand`.`name` AS `brand_name`,`motorcycle`.`model` AS `model`,`motorcycle`.`plate_number` AS `plate_number`,`motorcycle`.`cost` AS `cost`,`motorcycle`.`collateral` AS `collateral`,`motorcycle`.`price_per_day` AS `price_per_day`,`motorcycle`.`price_per_month` AS `price_per_month`,`motorcycle`.`status` AS `status` from (`brand` join `motorcycle`) where (`brand`.`id` = `motorcycle`.`brand_id`);

-- --------------------------------------------------------

--
-- Structure for view `rental_list`
--
DROP TABLE IF EXISTS `rental_list`;

CREATE ALGORITHM=MERGE DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `rental_list` AS select `rental`.`id` AS `id`,`motorcycle`.`id` AS `motorcycle_id`,`brand`.`name` AS `brand_name`,`motorcycle`.`model` AS `model`,`motorcycle`.`plate_number` AS `plate_number`,`motorcycle`.`status` AS `status`,`rental`.`firstname` AS `firstname`,`rental`.`lastname` AS `lastname`,`rental`.`date_rent` AS `date_rent`,`rental`.`date_return_expect` AS `date_return_expect`,`rental`.`date_return_returned` AS `date_return_returned` from ((`rental` join `motorcycle`) join `brand`) where ((`rental`.`motorcycle_id` = `motorcycle`.`id`) and (`motorcycle`.`brand_id` = `brand`.`id`)) order by `rental`.`date_rent` desc,`rental`.`id` desc;

-- --------------------------------------------------------

--
-- Structure for view `rental_view`
--
DROP TABLE IF EXISTS `rental_view`;

CREATE ALGORITHM=MERGE DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `rental_view` AS select `rental`.`id` AS `id`,`brand`.`name` AS `brand_name`,`motorcycle`.`model` AS `model`,`motorcycle`.`plate_number` AS `plate_number`,`motorcycle`.`collateral` AS `collateral`,`motorcycle`.`price_per_day` AS `price_per_day`,`motorcycle`.`price_per_month` AS `price_per_month`,`motorcycle`.`status` AS `status`,`rental`.`firstname` AS `firstname`,`rental`.`lastname` AS `lastname`,`rental`.`cznum` AS `cznum`,`rental`.`dlnum` AS `dlnum`,`rental`.`phone` AS `phone`,`rental`.`type` AS `type`,`rental`.`amount` AS `amount`,`rental`.`date_rent` AS `date_rent`,`rental`.`date_return_expect` AS `date_return_expect`,`rental`.`date_return_returned` AS `date_return_returned`,`rental`.`nrepair` AS `nrepair`,`rental`.`fine` AS `fine` from ((`rental` join `motorcycle`) join `brand`) where ((`rental`.`motorcycle_id` = `motorcycle`.`id`) and (`motorcycle`.`brand_id` = `brand`.`id`));

-- --------------------------------------------------------

--
-- Structure for view `repair_view`
--
DROP TABLE IF EXISTS `repair_view`;

CREATE ALGORITHM=MERGE DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `repair_view` AS select `repair`.`id` AS `id`,`motorcycle`.`id` AS `motorcycle_id`,`brand`.`name` AS `brand_name`,`motorcycle`.`model` AS `model`,`motorcycle`.`plate_number` AS `plate_number`,`motorcycle`.`status` AS `status`,`repair`.`problem` AS `problem`,`repair`.`cause` AS `cause`,`repair`.`cost` AS `cost`,date_format(`repair`.`date_send`,'%d %M %Y') AS `date_send`,date_format(`repair`.`date_return`,'%d %M %Y') AS `date_return` from ((`repair` join `motorcycle`) join `brand`) where ((`repair`.`motorcycle_id` = `motorcycle`.`id`) and (`motorcycle`.`brand_id` = `brand`.`id`));

--
-- Indexes for dumped tables
--

--
-- Indexes for table `brand`
--
ALTER TABLE `brand`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `motorcycle`
--
ALTER TABLE `motorcycle`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `rental`
--
ALTER TABLE `rental`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `repair`
--
ALTER TABLE `repair`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `brand`
--
ALTER TABLE `brand`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=13;
--
-- AUTO_INCREMENT for table `motorcycle`
--
ALTER TABLE `motorcycle`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=42;
--
-- AUTO_INCREMENT for table `rental`
--
ALTER TABLE `rental`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=12;
--
-- AUTO_INCREMENT for table `repair`
--
ALTER TABLE `repair`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=4;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
