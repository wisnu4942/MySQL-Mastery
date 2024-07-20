-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3307
-- Waktu pembuatan: 19 Jul 2024 pada 19.31
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `uas_pbd`
--

DELIMITER $$
--
-- Prosedur
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `calculateUserStats` ()   BEGIN
    DECLARE totalUsers INT;
    DECLARE avgHeartRate FLOAT;
    
    -- Calculate total users
    SELECT COUNT(*) INTO totalUsers FROM Users;
    
    -- Calculate average heart rate
    SELECT AVG(heart_rate) INTO avgHeartRate FROM HealthMetrics;
    
    -- Display the results
    SELECT CONCAT('Total Users: ', totalUsers) AS TotalUsers, 
           CONCAT('Average Heart Rate: ', avgHeartRate) AS AverageHeartRate;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `checkUserActivity` (`userId` INT, `activityDate` DATE)   BEGIN
    DECLARE totalCalories INT;
    
    -- Calculate total calories burned on the specified date
    SELECT SUM(calories_burned) INTO totalCalories
    FROM Activities
    WHERE user_id = userId AND DATE(start_time) = activityDate;
    
    -- Use IF statement to check if any activity was found
    IF totalCalories IS NULL THEN
        SELECT CONCAT('No activities found for user ID ', userId, ' on ', activityDate) AS Result;
    ELSE
        SELECT CONCAT('Total calories burned by user ID ', userId, ' on ', activityDate, ' is ', totalCalories) AS Result;
    END IF;
END$$

--
-- Fungsi
--
CREATE DEFINER=`root`@`localhost` FUNCTION `getAverageHeartRate` () RETURNS FLOAT DETERMINISTIC BEGIN
    DECLARE avgHeartRate FLOAT;
    SELECT AVG(heart_rate) INTO avgHeartRate FROM HealthMetrics;
    RETURN avgHeartRate;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `getTotalCaloriesBurned` (`userId` INT, `startDate` DATE, `endDate` DATE) RETURNS INT(11) DETERMINISTIC BEGIN
    DECLARE totalCalories INT;
    SELECT SUM(calories_burned) INTO totalCalories
    FROM Activities
    WHERE user_id = userId AND start_time >= startDate AND end_time <= endDate;
    RETURN totalCalories;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `activities`
--

CREATE TABLE `activities` (
  `activity_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `activity_type` varchar(50) DEFAULT NULL,
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `calories_burned` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `activities`
--

INSERT INTO `activities` (`activity_id`, `user_id`, `activity_type`, `start_time`, `end_time`, `calories_burned`) VALUES
(1, 1, 'Running', '2024-07-15 06:00:00', '2024-07-15 06:30:00', 200),
(2, 2, 'Walking', '2024-07-15 07:00:00', '2024-07-15 07:45:00', 150),
(3, 3, 'Cycling', '2024-07-15 08:00:00', '2024-07-15 08:45:00', 300),
(4, 4, 'Swimming', '2024-07-15 09:00:00', '2024-07-15 09:30:00', 250),
(5, 5, 'Yoga', '2024-07-15 10:00:00', '2024-07-15 10:30:00', 100),
(10, 1, 'Cycling', '2024-07-15 07:00:00', '2024-07-15 08:00:00', 300);

--
-- Trigger `activities`
--
DELIMITER $$
CREATE TRIGGER `after_activities_delete` AFTER DELETE ON `activities` FOR EACH ROW BEGIN
    DECLARE msg TEXT;
    SET msg = CONCAT('Deleted activity ID ', OLD.activity_id, ' of type ', OLD.activity_type, ', started at ', OLD.start_time, ' and ended at ', OLD.end_time, ', calories burned: ', OLD.calories_burned);
    INSERT INTO ActivityLog (action, table_name, old_data) VALUES ('AFTER DELETE', 'Activities', msg);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_activities_insert` AFTER INSERT ON `activities` FOR EACH ROW BEGIN
    DECLARE msg TEXT;
    SET msg = CONCAT('Inserted new activity for user ID ', NEW.user_id, ' of type ', NEW.activity_type, ' starting at ', NEW.start_time, ' and ending at ', NEW.end_time, ', calories burned: ', NEW.calories_burned);
    INSERT INTO ActivityLog (action, table_name, new_data) VALUES ('AFTER INSERT', 'Activities', msg);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_activities_update` AFTER UPDATE ON `activities` FOR EACH ROW BEGIN
    DECLARE msg TEXT;
    SET msg = CONCAT('Updated activity ID ', OLD.activity_id, ' from type ', OLD.activity_type, ' to ', NEW.activity_type, ', start_time from ', OLD.start_time, ' to ', NEW.start_time, ', end_time from ', OLD.end_time, ' to ', NEW.end_time, ', calories_burned from ', OLD.calories_burned, ' to ', NEW.calories_burned);
    INSERT INTO ActivityLog (action, table_name, old_data, new_data) VALUES ('AFTER UPDATE', 'Activities', msg, NULL);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `activitylog`
--

CREATE TABLE `activitylog` (
  `log_id` int(11) NOT NULL,
  `action` varchar(50) DEFAULT NULL,
  `table_name` varchar(50) DEFAULT NULL,
  `old_data` text DEFAULT NULL,
  `new_data` text DEFAULT NULL,
  `timestamp` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `activitylog`
--

INSERT INTO `activitylog` (`log_id`, `action`, `table_name`, `old_data`, `new_data`, `timestamp`) VALUES
(1, 'AFTER INSERT', 'Activities', NULL, 'Inserted new activity for user ID 1 of type Cycling starting at 2024-07-15 07:00:00 and ending at 2024-07-15 08:00:00, calories burned: 300', '2024-07-19 22:44:23'),
(2, 'AFTER INSERT', 'Activities', NULL, 'Inserted new activity for user ID 1 of type Cycling starting at 2024-07-15 07:00:00 and ending at 2024-07-15 08:00:00, calories burned: 300', '2024-07-19 22:44:57'),
(3, 'AFTER DELETE', 'Activities', 'Deleted activity ID 11 of type Cycling, started at 2024-07-15 07:00:00 and ended at 2024-07-15 08:00:00, calories burned: 300', NULL, '2024-07-19 22:45:26');

-- --------------------------------------------------------

--
-- Struktur dari tabel `alerts`
--

CREATE TABLE `alerts` (
  `alert_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `alert_type` varchar(50) DEFAULT NULL,
  `message` varchar(255) DEFAULT NULL,
  `timestamp` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `alerts`
--

INSERT INTO `alerts` (`alert_id`, `user_id`, `alert_type`, `message`, `timestamp`) VALUES
(1, 1, 'Heart Rate', 'Heart rate exceeded 90', '2024-07-15 08:15:00'),
(2, 2, 'Steps', 'Achieved daily goal', '2024-07-15 18:00:00'),
(3, 3, 'Sleep', 'Slept less than 6 hours', '2024-07-15 08:00:00'),
(4, 4, 'Activity', 'Did not meet activity goal', '2024-07-15 19:00:00'),
(5, 5, 'Calories', 'Burned more than 500 calories', '2024-07-15 20:00:00');

-- --------------------------------------------------------

--
-- Struktur dari tabel `devices`
--

CREATE TABLE `devices` (
  `device_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `serial_number` varchar(50) DEFAULT NULL,
  `purchase_date` date DEFAULT NULL,
  `warranty_status` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `devices`
--

INSERT INTO `devices` (`device_id`, `user_id`, `serial_number`, `purchase_date`, `warranty_status`) VALUES
(1, 1, 'SN123456', '2024-01-10', 'Active'),
(2, 2, 'SN654321', '2024-02-15', 'Active'),
(3, 3, 'SN789012', '2024-03-20', 'Expired'),
(4, 4, 'SN345678', '2024-04-25', 'Active'),
(5, 5, 'SN901234', '2024-05-30', 'Expired');

-- --------------------------------------------------------

--
-- Struktur dari tabel `doctors`
--

CREATE TABLE `doctors` (
  `doctor_id` int(11) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `specialization` varchar(100) DEFAULT NULL,
  `contact_info` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `doctors`
--

INSERT INTO `doctors` (`doctor_id`, `name`, `specialization`, `contact_info`) VALUES
(1, 'Dr. Adams', 'Cardiology', 'dr.adams@clinic.com'),
(2, 'Dr. Johnson', 'General Health', 'dr.johnson@clinic.com'),
(3, 'Dr. Lee', 'Orthopedics', 'dr.lee@clinic.com'),
(4, 'Dr. Taylor', 'Pediatrics', 'dr.taylor@clinic.com'),
(5, 'Dr. Martin', 'Neurology', 'dr.martin@clinic.com');

-- --------------------------------------------------------

--
-- Struktur dari tabel `healthmetrics`
--

CREATE TABLE `healthmetrics` (
  `metric_id` int(11) NOT NULL,
  `device_id` int(11) DEFAULT NULL,
  `timestamp` datetime DEFAULT NULL,
  `heart_rate` int(11) DEFAULT NULL,
  `steps` int(11) DEFAULT NULL,
  `sleep_hours` float DEFAULT NULL,
  `calories_burned` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `healthmetrics`
--

INSERT INTO `healthmetrics` (`metric_id`, `device_id`, `timestamp`, `heart_rate`, `steps`, `sleep_hours`, `calories_burned`) VALUES
(1, 1, '2024-07-15 08:00:00', 72, 5000, 7, 300),
(2, 2, '2024-07-15 08:00:00', 68, 4500, 6.5, 280),
(3, 3, '2024-07-15 08:00:00', 75, 5500, 8, 320),
(4, 4, '2024-07-15 08:00:00', 70, 6000, 7.5, 350),
(5, 5, '2024-07-15 08:00:00', 65, 4000, 6, 250);

--
-- Trigger `healthmetrics`
--
DELIMITER $$
CREATE TRIGGER `before_healthmetrics_delete` BEFORE DELETE ON `healthmetrics` FOR EACH ROW BEGIN
    DECLARE msg TEXT;
    SET msg = CONCAT('Deleting health metric with ID: ', OLD.metric_id, ', heart_rate: ', OLD.heart_rate, ', steps: ', OLD.steps, ', sleep_hours: ', OLD.sleep_hours, ', calories_burned: ', OLD.calories_burned);
    INSERT INTO ActivityLog (action, table_name, old_data) VALUES ('BEFORE DELETE', 'HealthMetrics', msg);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_healthmetrics_insert` BEFORE INSERT ON `healthmetrics` FOR EACH ROW BEGIN
    DECLARE msg TEXT;
    SET msg = CONCAT('Inserting new health metric with heart_rate: ', NEW.heart_rate, ', steps: ', NEW.steps, ', sleep_hours: ', NEW.sleep_hours, ', calories_burned: ', NEW.calories_burned);
    INSERT INTO ActivityLog (action, table_name, new_data) VALUES ('BEFORE INSERT', 'HealthMetrics', msg);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_healthmetrics_update` BEFORE UPDATE ON `healthmetrics` FOR EACH ROW BEGIN
    DECLARE msg TEXT;
    SET msg = CONCAT('Updating health metric ID ', OLD.metric_id, ' from heart_rate: ', OLD.heart_rate, ' to ', NEW.heart_rate, ', steps: ', OLD.steps, ' to ', NEW.steps, ', sleep_hours: ', OLD.sleep_hours, ' to ', NEW.sleep_hours, ', calories_burned: ', OLD.calories_burned, ' to ', NEW.calories_burned);
    INSERT INTO ActivityLog (action, table_name, old_data, new_data) VALUES ('BEFORE UPDATE', 'HealthMetrics', msg, NULL);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `highcalorieactivities`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `highcalorieactivities` (
`user_id` int(11)
,`name` varchar(100)
,`activity_type` varchar(50)
,`start_time` datetime
,`end_time` datetime
,`calories_burned` int(11)
);

-- --------------------------------------------------------

--
-- Struktur dari tabel `sleepquality`
--

CREATE TABLE `sleepquality` (
  `sleep_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `date` date DEFAULT NULL,
  `sleep_duration` float DEFAULT NULL,
  `sleep_quality` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `useractivities`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `useractivities` (
`user_id` int(11)
,`name` varchar(100)
,`activity_type` varchar(50)
,`start_time` datetime
,`end_time` datetime
,`calories_burned` int(11)
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `userhealthmetrics`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `userhealthmetrics` (
`user_id` int(11)
,`name` varchar(100)
,`avg_heart_rate` decimal(14,4)
);

-- --------------------------------------------------------

--
-- Struktur dari tabel `userprofile`
--

CREATE TABLE `userprofile` (
  `profile_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `phone_number` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `userprofile`
--

INSERT INTO `userprofile` (`profile_id`, `user_id`, `address`, `phone_number`) VALUES
(1, 1, '123 Elm Street', '555-1234'),
(2, 2, '980 Cendrawasih Street', '555-8869'),
(3, 3, '111 Luwak Street', '777-6543'),
(4, 4, '190 Kalimantan 1 Street', '876-0987'),
(5, 5, '456 Mawar Avenue', '889-8915');

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`user_id`, `name`, `email`, `date_of_birth`) VALUES
(1, 'John Doe', 'john@example.com', '1985-05-15'),
(2, 'Jane Smith', 'jane@example.com', '1990-07-22'),
(3, 'Alice Johnson', 'alice@example.com', '1992-08-30'),
(4, 'Bob Brown', 'bob@example.com', '1988-03-25'),
(5, 'Charlie Davis', 'charlie@example.com', '1995-12-11');

-- --------------------------------------------------------

--
-- Struktur dari tabel `user_doctors`
--

CREATE TABLE `user_doctors` (
  `user_id` int(11) NOT NULL,
  `doctor_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `user_doctors`
--

INSERT INTO `user_doctors` (`user_id`, `doctor_id`) VALUES
(1, 1),
(1, 2),
(2, 1),
(3, 3),
(4, 4),
(5, 5);

-- --------------------------------------------------------

--
-- Struktur untuk view `highcalorieactivities`
--
DROP TABLE IF EXISTS `highcalorieactivities`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `highcalorieactivities`  AS SELECT `useractivities`.`user_id` AS `user_id`, `useractivities`.`name` AS `name`, `useractivities`.`activity_type` AS `activity_type`, `useractivities`.`start_time` AS `start_time`, `useractivities`.`end_time` AS `end_time`, `useractivities`.`calories_burned` AS `calories_burned` FROM `useractivities` WHERE `useractivities`.`calories_burned` > 200WITH CASCADEDCHECK OPTION  ;

-- --------------------------------------------------------

--
-- Struktur untuk view `useractivities`
--
DROP TABLE IF EXISTS `useractivities`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `useractivities`  AS SELECT `u`.`user_id` AS `user_id`, `u`.`name` AS `name`, `a`.`activity_type` AS `activity_type`, `a`.`start_time` AS `start_time`, `a`.`end_time` AS `end_time`, `a`.`calories_burned` AS `calories_burned` FROM (`users` `u` join `activities` `a` on(`u`.`user_id` = `a`.`user_id`)) ;

-- --------------------------------------------------------

--
-- Struktur untuk view `userhealthmetrics`
--
DROP TABLE IF EXISTS `userhealthmetrics`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `userhealthmetrics`  AS SELECT `u`.`user_id` AS `user_id`, `u`.`name` AS `name`, avg(`hm`.`heart_rate`) AS `avg_heart_rate` FROM ((`users` `u` join `devices` `d` on(`u`.`user_id` = `d`.`user_id`)) join `healthmetrics` `hm` on(`d`.`device_id` = `hm`.`device_id`)) GROUP BY `u`.`user_id`, `u`.`name` ;

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `activities`
--
ALTER TABLE `activities`
  ADD PRIMARY KEY (`activity_id`),
  ADD KEY `idx_user_activity_type` (`user_id`,`activity_type`);

--
-- Indeks untuk tabel `activitylog`
--
ALTER TABLE `activitylog`
  ADD PRIMARY KEY (`log_id`);

--
-- Indeks untuk tabel `alerts`
--
ALTER TABLE `alerts`
  ADD PRIMARY KEY (`alert_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indeks untuk tabel `devices`
--
ALTER TABLE `devices`
  ADD PRIMARY KEY (`device_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indeks untuk tabel `doctors`
--
ALTER TABLE `doctors`
  ADD PRIMARY KEY (`doctor_id`);

--
-- Indeks untuk tabel `healthmetrics`
--
ALTER TABLE `healthmetrics`
  ADD PRIMARY KEY (`metric_id`),
  ADD KEY `idx_device_timestamp` (`device_id`,`timestamp`);

--
-- Indeks untuk tabel `sleepquality`
--
ALTER TABLE `sleepquality`
  ADD PRIMARY KEY (`sleep_id`),
  ADD KEY `user_id` (`user_id`,`date`);

--
-- Indeks untuk tabel `userprofile`
--
ALTER TABLE `userprofile`
  ADD PRIMARY KEY (`profile_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`);

--
-- Indeks untuk tabel `user_doctors`
--
ALTER TABLE `user_doctors`
  ADD PRIMARY KEY (`user_id`,`doctor_id`),
  ADD KEY `doctor_id` (`doctor_id`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `activities`
--
ALTER TABLE `activities`
  MODIFY `activity_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT untuk tabel `activitylog`
--
ALTER TABLE `activitylog`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT untuk tabel `alerts`
--
ALTER TABLE `alerts`
  MODIFY `alert_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `devices`
--
ALTER TABLE `devices`
  MODIFY `device_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `doctors`
--
ALTER TABLE `doctors`
  MODIFY `doctor_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `healthmetrics`
--
ALTER TABLE `healthmetrics`
  MODIFY `metric_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `sleepquality`
--
ALTER TABLE `sleepquality`
  MODIFY `sleep_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `userprofile`
--
ALTER TABLE `userprofile`
  MODIFY `profile_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `activities`
--
ALTER TABLE `activities`
  ADD CONSTRAINT `activities_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Ketidakleluasaan untuk tabel `alerts`
--
ALTER TABLE `alerts`
  ADD CONSTRAINT `alerts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Ketidakleluasaan untuk tabel `devices`
--
ALTER TABLE `devices`
  ADD CONSTRAINT `devices_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Ketidakleluasaan untuk tabel `healthmetrics`
--
ALTER TABLE `healthmetrics`
  ADD CONSTRAINT `healthmetrics_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `devices` (`device_id`);

--
-- Ketidakleluasaan untuk tabel `userprofile`
--
ALTER TABLE `userprofile`
  ADD CONSTRAINT `userprofile_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `user_doctors`
--
ALTER TABLE `user_doctors`
  ADD CONSTRAINT `user_doctors_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `user_doctors_ibfk_2` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`doctor_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
