-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Anamakine: 127.0.0.1
-- PHP Sürümü: 8.1.6

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Veritabanı: `db_gym`
--

DELIMITER $$
--
-- Yordamlar
--
CREATE DEFINER=`admin`@`localhost` PROCEDURE `/*sp_COACH_LIST_VARIABLE` (IN `p_LIST_ID` INT UNSIGNED)   BEGIN
	SELECT VARIABLE_ID, VARIABLE_VALUE FROM tb_list_variable WHERE LIST_ID = p_LIST_ID;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_CITY_LIST_GET` ()   BEGIN
	SELECT * FROM tb_city;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_COACH_AUTH` (IN `p_COACH_ID` INT UNSIGNED)   BEGIN
	SELECT ID, PASSWORD_HASH FROM tb_coach WHERE ID = p_COACH_ID AND VERIFIED = TRUE;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_COACH_EMAIL_UPDATE` (IN `p_COACH_ID` INT UNSIGNED, IN `p_NEW_EMAIL` VARCHAR(100) charset utf8)   BEGIN
	IF NOT EXISTS (SELECT ID FROM tb_coach WHERE EMAIL = p_NEW_EMAIL AND ID != p_COACH_ID) THEN
		SET SQL_SAFE_UPDATES = 0;
			UPDATE tb_coach SET EMAIL = p_NEW_EMAIL WHERE ID = p_COACH_ID;
        SET SQL_SAFE_UPDATES = 1;
        SELECT 'success' AS STATUS;
    ELSE
		SELECT 'email-already' AS STATUS;
    END IF;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_COACH_LIST` (IN `p_COACH_ID` INT UNSIGNED, IN `p_LIST_ID` INT UNSIGNED)   BEGIN
	SELECT 
		ID AS LIST_ID, 
        CATEGORY_ID,
        LIST_CODE, 
        LIST_NAME,
        HALL_NAME,
        GENDER,
        MEASURE_TYPE,
        WEIGHT_TYPE
	FROM tb_list WHERE
		COACH_ID = p_COACH_ID 
	AND
		ID = p_LIST_ID;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_COACH_LIST_CATEGORY_GET` ()   BEGIN
	SELECT ID AS CATEGORY_ID, CATEGORY_NAME FROM tb_category;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_COACH_LIST_CREATE` (IN `p_COACH_ID` INT UNSIGNED, IN `p_CATEGORY_ID` INT UNSIGNED, IN `p_LIST_CODE` VARCHAR(15) CHARSET utf8, IN `p_LIST_NAME` VARCHAR(300) CHARSET utf8, IN `p_HALL_NAME` VARCHAR(300) CHARSET utf8, IN `p_GENDER` TINYINT, IN `p_MEASURE_TYPE` VARCHAR(4), IN `p_WEIGHT_TYPE` VARCHAR(3))   BEGIN
	IF NOT EXISTS (SELECT ID FROM tb_list WHERE LIST_CODE = p_LIST_CODE) THEN
		INSERT INTO tb_list(
			COACH_ID,
            CATEGORY_ID,
            LIST_CODE,
            LIST_NAME,
            HALL_NAME,
            GENDER,
            MEASURE_TYPE,
            WEIGHT_TYPE
        ) VALUES (
			p_COACH_ID,
            p_CATEGORY_ID,
            p_LIST_CODE,
            p_LIST_NAME,
            p_HALL_NAME,
            p_GENDER,
            p_MEASURE_TYPE,
            p_WEIGHT_TYPE
        );
        SELECT LAST_INSERT_ID() AS LIST_ID;
        SELECT 'success' AS STATUS;
    ELSE
		SELECT 'code-already' AS STATUS;
    END IF;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_COACH_LIST_DELETE` (IN `p_COACH_ID` INT UNSIGNED, IN `p_LIST_ID` INT UNSIGNED)   BEGIN
	SET SQL_SAFE_UPDATES = 0;
		DELETE FROM tb_list WHERE ID = p_LIST_ID AND COACH_ID = p_COACH_ID;
        DELETE FROM tb_list_variable WHERE LIST_ID = p_LIST_ID;
    SET SQL_SAFE_UPDATES = 1;
    SELECT 'success' AS STATUS;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_COACH_LIST_TABLE` (IN `p_COACH_ID` INT UNSIGNED)   BEGIN
	SELECT 
		ID AS LIST_ID, 
		LIST_CODE, 
		LIST_NAME, date_format(CREATED_DATE, '%d/%m/%Y %H:%i') AS CREATED_DATE, 
		( SELECT COUNT(USER_ID) OVER() FROM tb_list_used_by_user 
		WHERE tb_list_used_by_user.LIST_ID = tb_list.ID GROUP BY USER_ID LIMIT 1 ) AS USER_COUNT 
	FROM 
		tb_list 
	WHERE COACH_ID = p_COACH_ID GROUP BY ID DESC;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_COACH_LIST_UPDATE` (IN `p_COACH_ID` INT UNSIGNED, IN `p_LIST_ID` INT UNSIGNED, IN `p_CATEGORY_ID` INT UNSIGNED, IN `p_LIST_NAME` VARCHAR(300) CHARSET utf8, IN `p_HALL_NAME` VARCHAR(300) CHARSET utf8, IN `p_GENDER` TINYINT, IN `p_MEASURE_TYPE` VARCHAR(4), IN `p_WEIGHT_TYPE` VARCHAR(3))   BEGIN
	SET SQL_SAFE_UPDATES = 0;
		UPDATE tb_list SET
            CATEGORY_ID = p_CATEGORY_ID,
            LIST_NAME = p_LIST_NAME,
            HALL_NAME = p_HALL_NAME,
            GENDER = p_GENDER,
            MEASURE_TYPE = p_MEASURE_TYPE,
            WEIGHT_TYPE = p_WEIGHT_TYPE
		WHERE ID = p_LIST_ID AND COACH_ID = p_COACH_ID;
    SET SQL_SAFE_UPDATES = 1;
    SELECT 'success' AS STATUS;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_COACH_LIST_VARIABLE` (IN `p_LIST_ID` INT UNSIGNED)   BEGIN
	SELECT VARIABLE_ID, VARIABLE_VALUE FROM tb_list_variable WHERE LIST_ID = p_LIST_ID;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_COACH_LIST_VARIABLE_ADD` (IN `p_LIST_ID` INT UNSIGNED, IN `p_VARIABLE_ID` INT UNSIGNED, IN `p_VARIABLE_VALUE` VARCHAR(100) charset utf8)   BEGIN
	SET @ID = (SELECT ID FROM tb_list_variable WHERE LIST_ID = p_LIST_ID AND VARIABLE_ID = p_VARIABLE_ID);
    
	IF (@ID) THEN
		SET SQL_SAFE_UPDATES = 0;
			UPDATE tb_list_variable SET VARIABLE_VALUE = p_VARIABLE_VALUE WHERE ID = @ID;
        SET SQL_SAFE_UPDATES = 1;
    ELSE
		INSERT INTO tb_list_variable (
			LIST_ID,
            VARIABLE_ID,
            VARIABLE_VALUE
        ) VALUES (
			p_LIST_ID,
            p_VARIABLE_ID,
            p_VARIABLE_VALUE
        );
    END IF;
    
    SELECT 'success' AS STATUS;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_COACH_LIST_VARIABLE_GET` ()   BEGIN
	SELECT ID AS VARIABLE_ID, TITLE FROM tb_variable;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_COACH_LIST_VARIABLE_WITH_TITLE` (IN `p_LIST_ID` INT UNSIGNED)   BEGIN
	SELECT 
		vl.LIST_ID,
		vl.VARIABLE_ID,
        vl.VARIABLE_VALUE,
		v.TITLE
	FROM 
		tb_list_variable vl
	INNER JOIN
		tb_variable v
	ON
		vl.VARIABLE_ID = v.ID
	WHERE 
		vl.LIST_ID = p_LIST_ID;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_COACH_LOGIN_WITH_EMAIL` (IN `p_EMAIL` VARCHAR(150) charset utf8)   BEGIN
	SET @COACH_ID = (SELECT ID FROM tb_coach WHERE EMAIL = p_EMAIL);
    
    IF (@COACH_ID) THEN
		IF EXISTS (SELECT ID FROM tb_coach WHERE ID = @COACH_ID AND VERIFIED = TRUE) THEN
			SELECT ID AS COACH_ID, FIRSTNAME, LASTNAME, EMAIL, date_format(REGISTER_DATE, '%d.%m.%Y') AS REGISTER_DATE, PASSWORD_HASH FROM tb_coach WHERE ID = @COACH_ID;
        ELSE
			SELECT 'account-unverified' AS STATUS;
        END IF;
    ELSE
		SELECT 'email-or-password-wrong' AS STATUS;
    END IF;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_COACH_LOGIN_WITH_FACEBOOK` (IN `p_FACEBOOK_ID` VARCHAR(100) charset utf8, IN `p_FIRSTNAME` VARCHAR(100) charset utf8, IN `p_LASTNAME` VARCHAR(100) charset utf8, IN `p_EMAIL` VARCHAR(150) charset utf8, IN `p_REGISTER_IP` VARCHAR(15) charset utf8)   BEGIN
	SET @COACH_ID = (SELECT ID FROM tb_coach WHERE FACEBOOK_ID = p_FACEBOOK_ID);
    
    IF(@COACH_ID) THEN
		SELECT ID AS COACH_ID, FIRSTNAME, LASTNAME FROM tb_coach WHERE ID = @COACH_ID;
		SELECT 'success' AS STATUS;
    ELSE
		INSERT INTO tb_coach (
			FACEBOOK_ID,
            FIRSTNAME,
            LASTNAME,
            EMAIL,
            VERIFIED,
            VERIFY_CODE,
            REGISTER_IP
        ) VALUES (
			p_FACEBOOK_ID,
            p_FIRSTNAME,
            p_LASTNAME,
            p_EMAIL,
            true,
            null,
            p_REGISTER_IP
        );
        SELECT LAST_INSERT_ID() AS COACH_ID, p_FIRSTNAME AS FIRSTNAME, p_LASTNAME AS LASTNAME;
        SELECT 'success' AS STATUS;
    END IF;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_COACH_LOGIN_WITH_GOOGLE` (IN `p_EMAIL` VARCHAR(150) charset utf8, IN `p_FIRSTNAME` VARCHAR(100) charset utf8, IN `p_LASTNAME` VARCHAR(100) charset utf8, IN `p_REGISTER_IP` VARCHAR(15) charset utf8)   BEGIN
	SET @COACH_ID = (SELECT ID FROM tb_coach WHERE EMAIL = p_EMAIL AND PASSWORD_HASH IS NULL);
    
    IF(@COACH_ID) THEN
		SELECT ID AS COACH_ID, FIRSTNAME, LASTNAME FROM tb_coach WHERE ID = @COACH_ID;
		SELECT 'success' AS STATUS;
    ELSE
		INSERT INTO tb_coach (
            FIRSTNAME,
            LASTNAME,
            EMAIL,
            VERIFIED,
            VERIFY_CODE,
            REGISTER_IP
        ) VALUES (
            p_FIRSTNAME,
            p_LASTNAME,
            p_EMAIL,
            true,
            null,
            p_REGISTER_IP
        );
        SELECT LAST_INSERT_ID() AS COACH_ID, p_FIRSTNAME AS FIRSTNAME, p_LASTNAME AS LASTNAME;
        SELECT 'success' AS STATUS;
    END IF;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_COACH_NEW_PASSWORD_SET` (IN `p_COACH_ID` INT UNSIGNED, IN `p_RESET_CODE` CHAR(6) charset utf8, IN `p_NEW_PASSWORD_HASH` VARCHAR(100) charset utf8)   BEGIN
	SET @RESET_ID = (SELECT ID FROM tb_coach_password_reset WHERE COACH_ID = p_COACH_ID AND RESET_CODE = p_RESET_CODE);
    
    IF (@RESET_ID) THEN
		SET SQL_SAFE_UPDATES = 0;
			DELETE FROM tb_coach_password_reset WHERE COACH_ID = p_COACH_ID;
            UPDATE tb_coach SET PASSWORD_HASH = p_NEW_PASSWORD_HASH WHERE ID = p_COACH_ID;
        SET SQL_SAFE_UPDATES = 1;
        SELECT 'success' AS STATUS;
    ELSE
		SELECT 'invalid-code' AS STATUS;
    END IF;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_COACH_PASSWORD_RESET_CODE_VERIFY` (IN `p_EMAIL` VARCHAR(150) charset utf8, IN `p_RESET_CODE` CHAR(6) charset utf8)   BEGIN
	SET @COACH_ID = (SELECT ID FROM tb_coach WHERE EMAIL = p_EMAIL);
    
	IF EXISTS (SELECT ID FROM tb_coach_password_reset WHERE COACH_ID = @COACH_ID AND RESET_CODE = p_RESET_CODE) THEN
		SELECT 'success' AS STATUS;
        SELECT @COACH_ID AS COACH_ID;
    ELSE
		SELECT 'invalid-code' AS STATUS;
    END IF;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_COACH_PASSWORD_RESET_CREATE` (IN `p_EMAIL` VARCHAR(150) charset utf8, IN `p_RESET_CODE` CHAR(6) charset utf8, IN `p_REQUEST_IP` VARCHAR(15) charset utf8)   BEGIN
	SET @COACH_ID = (SELECT ID FROM tb_coach WHERE EMAIL = p_EMAIL AND VERIFIED = TRUE);
	
    IF (@COACH_ID) THEN
		INSERT INTO tb_coach_password_reset (
			COACH_ID,
            RESET_CODE,
            REQUEST_IP
        ) VALUES (
			@COACH_ID,
            p_RESET_CODE,
            p_REQUEST_IP
        );
        SELECT 'success' AS STATUS;
    ELSE
		SELECT 'email-not-found' AS STATUS;
    END IF;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_COACH_PASSWORD_UPDATE` (IN `p_COACH_ID` INT UNSIGNED, IN `p_NEW_PASSWORD_HASH` VARCHAR(100) charset utf8)   BEGIN
	SET SQL_SAFE_UPDATES = 0;
		UPDATE tb_coach SET 
			PASSWORD_HASH = p_NEW_PASSWORD_HASH
		WHERE ID = p_COACH_ID;
	SET SQL_SAFE_UPDATES = 1;
	SELECT 'success' AS STATUS;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_COACH_PROFILE_UPDATE` (IN `p_COACH_ID` INT UNSIGNED, IN `p_NEW_FIRSTNAME` VARCHAR(100) charset utf8, IN `p_NEW_LASTNAME` VARCHAR(100) charset utf8)   BEGIN
	SET SQL_SAFE_UPDATES = 0;
		UPDATE tb_coach SET 
			FIRSTNAME = p_NEW_FIRSTNAME, 
            LASTNAME = p_NEW_LASTNAME 
		WHERE ID = p_COACH_ID;
	SET SQL_SAFE_UPDATES = 1;
	SELECT 'success' AS STATUS;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_COACH_REGISTER_WITH_EMAIL` (IN `p_FIRSTNAME` VARCHAR(100) charset utf8, IN `p_LASTNAME` VARCHAR(100) charset utf8, IN `p_EMAIL` VARCHAR(150) charset utf8, IN `p_PASSWORD_HASH` VARCHAR(100) charset utf8, IN `p_VERIFY_CODE` CHAR(8) charset utf8, IN `p_REGISTER_IP` VARCHAR(15) charset utf8)   BEGIN
	IF NOT EXISTS (SELECT ID FROM tb_coach WHERE EMAIL = p_EMAIL) THEN
		INSERT INTO tb_coach(
			FIRSTNAME,
            LASTNAME,
            EMAIL,
            PASSWORD_HASH,
            VERIFY_CODE,
            REGISTER_IP
        ) VALUES (
			p_FIRSTNAME,
            p_LASTNAME,
            p_EMAIL,
            p_PASSWORD_HASH,
            p_VERIFY_CODE,
            p_REGISTER_IP
        );
        
        SELECT LAST_INSERT_ID() AS COACH_ID;
        SELECT 'success' AS STATUS;
    ELSE
		SELECT 'email-already' AS STATUS;
    END IF;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_COACH_USER_DELETE` (IN `p_COACH_ID` INT UNSIGNED, IN `p_USER_ID` INT UNSIGNED)   BEGIN
	IF EXISTS (SELECT ID FROM tb_list_used_by_user WHERE USER_ID = p_USER_ID AND COACH_ID = p_COACH_ID) THEN
		SET SQL_SAFE_UPDATES = 0;
			DELETE FROM tb_user WHERE ID = p_USER_ID;
			DELETE FROM tb_user_variable WHERE USER_ID = p_USER_ID;
            DELETE FROM tb_list_used_by_user WHERE USER_ID = p_USER_ID;
		SET SQL_SAFE_UPDATES = 1;
		SELECT 'success' AS STATUS;
    ELSE
		SELECT 'user-not-found' AS STATUS;
    END IF;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_COACH_USER_PROFILE` (IN `p_COACH_ID` INT UNSIGNED, IN `p_USER_ID` INT UNSIGNED)   BEGIN
    IF EXISTS (SELECT ID FROM tb_list_used_by_user WHERE USER_ID = p_USER_ID AND COACH_ID = p_COACH_ID) THEN
		SELECT
			u.FIRSTNAME,
			u.LASTNAME,
			u.EMAIL,
			u.GENDER,
			c.NAME AS CITY_NAME,
			s.NAME AS STATE_NAME,
			u.AGE
		FROM tb_user u
		INNER JOIN tb_city c
		ON u.CITY_ID = c.ID
		INNER JOIN tb_state s
		ON u.STATE_ID = s.ID
		WHERE u.ID = p_USER_ID;
    END IF;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_COACH_USER_PROFILE_VARIABLE` (IN `p_USER_ID` INT UNSIGNED)   BEGIN
	SELECT 
		u.VARIABLE_ID,
		u.VARIABLE_VALUE_START,
		u.VARIABLE_VALUE_END,
		v.TITLE
	FROM 
		tb_user_variable u
	INNER JOIN
		tb_variable v
	ON
		u.VARIABLE_ID = v.ID
	WHERE 
		u.USER_ID = p_USER_ID;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_COACH_USER_REGISTER` (IN `p_COACH_ID` INT UNSIGNED, IN `p_FIRSTNAME` VARCHAR(100) charset utf8, IN `p_LASTNAME` VARCHAR(100) charset utf8, IN `p_EMAIL` VARCHAR(150) charset utf8, IN `p_GENDER` TINYINT, IN `p_AGE` VARCHAR(10), IN `p_CITY_ID` INT UNSIGNED, IN `p_STATE_ID` INT UNSIGNED, IN `p_PASSWORD_HASH` VARCHAR(100))   BEGIN
	IF NOT EXISTS (SELECT ID FROM tb_user WHERE EMAIL = p_EMAIL) THEN
		INSERT INTO tb_user (
            FIRSTNAME,
            LASTNAME,
            EMAIL,
            GENDER,
            AGE,
            CITY_ID,
            STATE_ID,
            PASSWORD_HASH,
            VERIFIED
        ) VALUES (
			p_FIRSTNAME,
            p_LASTNAME,
            p_EMAIL,
            p_GENDER,
            p_AGE,
            p_CITY_ID,
            p_STATE_ID,
            p_PASSWORD_HASH,
            TRUE
        );
        SET @USER_ID = (SELECT LAST_INSERT_ID());
        
		insert into tb_list_used_by_user(
			USER_ID,
			COACH_ID
		) VALUES (
			@USER_ID,
			p_COACH_ID
		);
		
        SELECT @USER_ID AS USER_ID;
        SELECT 'success' AS STATUS;
    ELSE
		SELECT 'email-already' AS STATUS;
    END IF;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_COACH_USER_REGISTER_VARIABLE_ADD` (IN `p_USER_ID` INT UNSIGNED, IN `p_VARIABLE_ID` INT UNSIGNED, IN `p_VARIABLE_VALUE_START` VARCHAR(100) charset utf8)   BEGIN
	INSERT INTO tb_user_variable(
		USER_ID,
        VARIABLE_ID,
        VARIABLE_VALUE_START
    ) VALUES (
		p_USER_ID,
        p_VARIABLE_ID,
        p_VARIABLE_VALUE_START
    );
    SELECT 'success' AS STATUS;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_COACH_USER_TABLE` (IN `p_COACH_ID` INT UNSIGNED)   BEGIN
	SELECT 
		v.USER_ID, 
		u.FIRSTNAME, 
		u.LASTNAME,
		u.GENDER,
		u.EMAIL, 
		date_format(u.CREATED_DATE, '%d/%m/%Y %H:%i') AS CREATED_DATE, 
		date_format(uv.LAST_UPDATED, '%d/%m/%Y %H:%i') AS LAST_UPDATED 
	FROM tb_list_used_by_user v 
	INNER JOIN tb_user u 
	ON v.USER_ID = u.ID 
	INNER JOIN tb_user_variable uv
	ON v.USER_ID = uv.USER_ID
	WHERE v.COACH_ID = p_COACH_ID
	GROUP BY u.ID DESC;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_COACH_VERIFY_ACCOUNT` (IN `p_COACH_ID` INT UNSIGNED, IN `p_VERIFY_CODE` CHAR(8) charset utf8)   BEGIN
	IF EXISTS (SELECT ID FROM tb_coach WHERE ID = p_COACH_ID AND VERIFY_CODE = p_VERIFY_CODE AND VERIFIED = FALSE) THEN
		SET SQL_SAFE_UPDATES = 0;
			UPDATE tb_coach SET VERIFY_CODE = NULL, VERIFIED = TRUE WHERE ID = p_COACH_ID;
        SET SQL_SAFE_UPDATES = 1;
        SELECT 'success' AS STATUS;
    ELSE
		SELECT 'invalid-code' AS STATUS;
    END IF;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_LIST_CURRENT_NAME_GET` (IN `p_USER_ID` INT UNSIGNED)   BEGIN
	SELECT 
		l.ID AS LIST_ID, 
		l.LIST_NAME, 
        l.LIST_CODE 
	FROM 
		tb_list_used_by_user ul
    INNER JOIN tb_list l 
    ON ul.LIST_ID = l.ID 
    WHERE ul.USER_ID = p_USER_ID GROUP BY ul.ID DESC;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_PUBLIC_APP_ABOUT` (IN `p_ABOUT_TYPE` BOOLEAN)   BEGIN
	IF (p_ABOUT_TYPE) THEN
		SELECT TERMS FROM tb_app_about;
    ELSE
		SELECT PRIVACY FROM tb_app_about;
    END IF;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_STATE_LIST_GET` (IN `p_CITY_ID` INT UNSIGNED)   BEGIN
	SELECT * FROM tb_state WHERE CITY_ID = p_CITY_ID;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_USER_AUTH` (IN `p_USER_ID` INT UNSIGNED)   BEGIN
	SELECT ID, PASSWORD_HASH FROM tb_user WHERE ID = p_USER_ID AND VERIFIED = TRUE;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_USER_LIST_CURRENT_GET` (IN `p_USER_ID` INT UNSIGNED)   BEGIN
	SELECT 
		u.VARIABLE_ID,
		v.TITLE,
		u.VARIABLE_VALUE_START,
		u.VARIABLE_VALUE_END,
		date_format(u.LAST_UPDATED, '%d/%m/%Y') AS LAST_UPDATED
	FROM 
		tb_user_variable u
	INNER JOIN
		tb_variable v
	ON
		u.VARIABLE_ID = v.ID
	WHERE 
		u.USER_ID = p_USER_ID;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_USER_LIST_CURRENT_SET` (IN `p_USER_ID` INT UNSIGNED, IN `p_VARIABLE_ID` INT UNSIGNED, IN `p_VARIABLE_VALUE_START` VARCHAR(100))   BEGIN
    INSERT INTO tb_user_variable(
		USER_ID,
		VARIABLE_ID,
		VARIABLE_VALUE_START
	) VALUES (
		p_USER_ID,
		p_VARIABLE_ID,
		p_VARIABLE_VALUE_START
	);
	SELECT 'success' AS STATUS;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_USER_LIST_CURRENT_UPDATE` (IN `p_USER_ID` INT UNSIGNED, IN `p_VARIABLE_ID` INT UNSIGNED, IN `p_VARIABLE_VALUE_START` VARCHAR(100))   BEGIN
	SET SQL_SAFE_UPDATES = 0;
		UPDATE tb_user_variable SET
			VARIABLE_VALUE_START = p_VARIABLE_VALUE_START,
			LAST_UPDATED = CURRENT_DATE()
		WHERE USER_ID = p_USER_ID AND VARIABLE_ID = p_VARIABLE_ID;
	SET SQL_SAFE_UPDATES = 1;
	SELECT 'success' AS STATUS;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_USER_LIST_DETAIL` (IN `p_USER_ID` INT UNSIGNED, IN `p_LIST_ID` INT UNSIGNED)   BEGIN
	SELECT 
		lv.VARIABLE_ID,
		lv.VARIABLE_VALUE,
		uv.VARIABLE_VALUE_START,
		v.TITLE,
		date_format(uv.LAST_UPDATED, '%d/%m/%Y') AS LAST_UPDATED
	FROM 
		tb_list_variable lv
	INNER JOIN
		tb_user_variable uv
	ON
		lv.VARIABLE_ID = uv.VARIABLE_ID
	INNER JOIN
		tb_variable v
	ON
		lv.VARIABLE_ID = v.ID
	WHERE lv.LIST_ID = p_LIST_ID AND uv.USER_ID = p_USER_ID;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_USER_LIST_DETAIL_DELETE` (IN `p_USER_ID` INT UNSIGNED, IN `p_LIST_ID` INT UNSIGNED)   BEGIN
	SET SQL_SAFE_UPDATES = 0;
		DELETE FROM tb_list_used_by_user WHERE USER_ID = p_USER_ID AND LIST_ID = p_LIST_ID;
        DELETE FROM tb_user_list_share WHERE USER_ID = p_USER_ID AND LIST_ID = p_LIST_ID;
    SET SQL_SAFE_UPDATES = 1;
    SELECT 'success' AS STATUS;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_USER_LIST_GET` (IN `p_LIST_CODE` VARCHAR(15) charset utf8, IN `p_USER_ID` INT UNSIGNED)   BEGIN
	SELECT 
		l.ID AS LIST_ID, 
        l.LIST_CODE,
        l.LIST_NAME, 
        l.HALL_NAME, 
        ct.ID AS CATEGORY_ID,
        ct.CATEGORY_NAME,
        l.GENDER,
        l.MEASURE_TYPE, 
        l.WEIGHT_TYPE,
        sh.SHARE_CODE AS LIST_SHARE_CODE
        /*c.FIRSTNAME, 
        c.LASTNAME, 
		date_format(c.REGISTER_DATE, '%d/%m/%Y') AS REGISTER_DATE, 
        ( SELECT COUNT(USER_ID) OVER() FROM tb_list_used_by_user 
		WHERE tb_list_used_by_user.LIST_ID = l.ID GROUP BY USER_ID LIMIT 1 ) AS USER_COUNT*/
	FROM 
		tb_list l 
    INNER JOIN 
		tb_coach c 
	ON l.COACH_ID = c.ID 
	INNER JOIN 
		tb_category ct 
	ON l.CATEGORY_ID = ct.ID 
	INNER JOIN 
		tb_user_list_share sh
	ON l.ID = sh.LIST_ID
    WHERE 
		l.LIST_CODE = p_LIST_CODE OR l.ID = p_LIST_CODE AND sh.USER_ID = p_USER_ID;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_USER_LIST_GET_WITHOUT_SHARED` (IN `p_LIST_CODE` VARCHAR(15) charset utf8, IN `p_USER_ID` INT UNSIGNED)   BEGIN
	SELECT 
		l.ID AS LIST_ID, 
        l.LIST_CODE,
        l.LIST_NAME, 
        l.HALL_NAME, 
        ct.ID AS CATEGORY_ID,
        ct.CATEGORY_NAME,
        l.GENDER,
        l.MEASURE_TYPE, 
        l.WEIGHT_TYPE
        /*c.FIRSTNAME, 
        c.LASTNAME, 
		date_format(c.REGISTER_DATE, '%d/%m/%Y') AS REGISTER_DATE, 
        ( SELECT COUNT(USER_ID) OVER() FROM tb_list_used_by_user 
		WHERE tb_list_used_by_user.LIST_ID = l.ID GROUP BY USER_ID LIMIT 1 ) AS USER_COUNT*/
	FROM 
		tb_list l 
    INNER JOIN 
		tb_coach c 
	ON l.COACH_ID = c.ID 
	INNER JOIN 
		tb_category ct 
	ON l.CATEGORY_ID = ct.ID 
    WHERE 
		l.LIST_CODE = p_LIST_CODE OR l.ID = p_LIST_CODE;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_USER_LIST_GET_WITH_CODE` (IN `p_SHARE_CODE` CHAR(8) charset utf8)   BEGIN
	SELECT USER_ID, LIST_ID FROM tb_user_list_share WHERE SHARE_CODE = p_SHARE_CODE;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_USER_LIST_SAVE` (IN `p_USER_ID` INT UNSIGNED, IN `p_LIST_ID` INT UNSIGNED, IN `p_SHARE_CODE` CHAR(8) charset utf8)   BEGIN
	IF NOT EXISTS (SELECT ID FROM tb_list_used_by_user WHERE USER_ID = p_USER_ID AND LIST_ID = p_LIST_ID) THEN
    
        SET @COACH_ID = (SELECT COACH_ID FROM tb_list WHERE ID = p_LIST_ID);
        
        SET @USED_ID = (SELECT ID FROM tb_list_used_by_user WHERE USER_ID = p_USER_ID AND COACH_ID = @COACH_ID AND LIST_ID IS NULL);
        IF(@USED_ID) THEN
			SET SQL_SAFE_UPDATES = 0;
				DELETE FROM tb_list_used_by_user WHERE ID = @USER_ID;
            SET SQL_SAFE_UPDATES = 1;
        END IF;
        
        INSERT INTO tb_list_used_by_user (
			USER_ID,
            COACH_ID,
            LIST_ID
        ) VALUES (
			p_USER_ID,
            @COACH_ID,
            p_LIST_ID
        );
        
        INSERT INTO tb_user_list_share (
			SHARE_CODE,
            USER_ID,
            LIST_ID
        ) VALUES (
			p_SHARE_CODE,
            p_USER_ID,
            p_LIST_ID
        );
        
        SELECT 'success' AS STATUS;
    ELSE
		SELECT 'list-used' AS STATUS;
    END IF;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_USER_LOGIN_WITH_EMAIL` (IN `p_EMAIL` VARCHAR(150) charset utf8)   BEGIN
	SET @USER_ID = (SELECT ID FROM tb_user WHERE EMAIL = p_EMAIL AND FACEBOOK_ID IS NULL);
    
    IF (@USER_ID) THEN
		IF EXISTS (SELECT ID FROM tb_user WHERE ID = @USER_ID AND VERIFIED = TRUE ) THEN
			SELECT 
				ID AS USER_ID, 
                FIRSTNAME, 
                LASTNAME, 
                EMAIL,
                GENDER,
                AGE,
                date_format(CREATED_DATE, '%d.%m.%Y') AS CREATED_DATE, 
                PASSWORD_HASH 
			FROM tb_user WHERE ID = @USER_ID;
            
            IF EXISTS (SELECT ID FROM tb_user_variable WHERE USER_ID = @USER_ID LIMIT 1) THEN
				SELECT 'success' AS BODY_STATUS;
            ELSE
				SELECT 'body-size-not-found' AS BODY_STATUS;
            END IF;
        ELSE
			SELECT 'account-unverified' AS STATUS;
        END IF;
    ELSE
		SELECT 'email-or-password-wrong' AS STATUS;
    END IF;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_USER_LOGIN_WITH_FACEBOOK` (IN `p_FACEBOOK_ID` VARCHAR(150) charset utf8)   BEGIN
	SET @USER_ID = (SELECT ID FROM tb_user WHERE FACEBOOK_ID = p_FACEBOOK_ID);
    
    IF (@USER_ID) THEN
		SELECT 
			ID AS USER_ID, 
			FIRSTNAME, 
			LASTNAME, 
			EMAIL,
			GENDER,
			AGE,
			date_format(CREATED_DATE, '%d.%m.%Y') AS CREATED_DATE, 
			PASSWORD_HASH 
		FROM tb_user WHERE ID = @USER_ID;
        
        IF EXISTS (SELECT ID FROM tb_user_variable WHERE USER_ID = @USER_ID LIMIT 1) THEN
			SELECT 'success' AS BODY_STATUS;
		ELSE
			SELECT 'body-size-not-found' AS BODY_STATUS;
		END IF;
            
    ELSE
		SELECT 'user-not-found' AS STATUS;
    END IF;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_USER_NEW_PASSWORD_SET` (IN `p_USER_ID` INT UNSIGNED, IN `p_RESET_CODE` CHAR(6) charset utf8, IN `p_NEW_PASSWORD_HASH` VARCHAR(100) charset utf8)   BEGIN
	SET @RESET_ID = (SELECT ID FROM tb_user_password_reset WHERE USER_ID = p_USER_ID AND RESET_CODE = p_RESET_CODE);
    
    IF (@RESET_ID) THEN
		SET SQL_SAFE_UPDATES = 0;
			DELETE FROM tb_user_password_reset WHERE USER_ID = p_USER_ID;
            UPDATE tb_user SET PASSWORD_HASH = p_NEW_PASSWORD_HASH WHERE ID = p_USER_ID;
        SET SQL_SAFE_UPDATES = 1;
        SELECT 'success' AS STATUS;
    ELSE
		SELECT 'invalid-code' AS STATUS;
    END IF;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_USER_PASSWORD_RESET_CODE_VERIFY` (IN `p_EMAIL` VARCHAR(150) charset utf8, IN `p_RESET_CODE` CHAR(6) charset utf8)   BEGIN
	SET @USER_ID = (SELECT ID FROM tb_user WHERE EMAIL = p_EMAIL);
    
	IF EXISTS (SELECT ID FROM tb_user_password_reset WHERE USER_ID = @USER_ID AND RESET_CODE = p_RESET_CODE) THEN
		SELECT 'success' AS STATUS;
        SELECT @USER_ID AS USER_ID;
    ELSE
		SELECT 'invalid-code' AS STATUS;
    END IF;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_USER_PASSWORD_RESET_CREATE` (IN `p_EMAIL` VARCHAR(150) charset utf8, IN `p_RESET_CODE` CHAR(6) charset utf8, IN `p_REQUEST_IP` VARCHAR(15) charset utf8)   BEGIN
	SET @USER_ID = (SELECT ID FROM tb_user WHERE EMAIL = p_EMAIL AND VERIFIED = TRUE);
	
    IF (@USER_ID) THEN
		INSERT INTO tb_user_password_reset (
			USER_ID,
            RESET_CODE,
            REQUEST_IP
        ) VALUES (
			@USER_ID,
            p_RESET_CODE,
            p_REQUEST_IP
        );
        SELECT 'success' AS STATUS;
    ELSE
		SELECT 'email-not-found' AS STATUS;
    END IF;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_USER_PASSWORD_UPDATE` (IN `p_USER_ID` INT UNSIGNED, IN `p_NEW_PASSWORD_HASH` VARCHAR(100) charset utf8)   BEGIN
	SET SQL_SAFE_UPDATES = 0;
		UPDATE tb_user SET 
			PASSWORD_HASH = p_NEW_PASSWORD_HASH
		WHERE ID = p_USER_ID;
	SET SQL_SAFE_UPDATES = 1;
	SELECT 'success' AS STATUS;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_USER_PROFILE_GET` (IN `p_USER_ID` INT UNSIGNED)   BEGIN
	SELECT FIRSTNAME, LASTNAME, EMAIL, GENDER, AGE, CITY_ID, STATE_ID FROM tb_user WHERE ID = p_USER_ID;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_USER_PROFILE_UPDATE` (IN `p_USER_ID` INT UNSIGNED, IN `p_NEW_FIRSTNAME` VARCHAR(100) charset utf8, IN `p_NEW_LASTNAME` VARCHAR(100) charset utf8, IN `p_NEW_GENDER` TINYINT(4), IN `p_NEW_AGE` VARCHAR(10) charset utf8, IN `p_NEW_CITY_ID` INT UNSIGNED, IN `p_NEW_STATE_ID` INT UNSIGNED)   BEGIN
	SET SQL_SAFE_UPDATES = 0;
		UPDATE tb_user SET 
			FIRSTNAME = p_NEW_FIRSTNAME,
            LASTNAME = p_NEW_LASTNAME,
            GENDER = p_NEW_GENDER,
            AGE = p_NEW_AGE,
            CITY_ID = p_NEW_CITY_ID,
            STATE_ID = p_NEW_STATE_ID
		WHERE ID = p_USER_ID;
	SET SQL_SAFE_UPDATES = 1;
	SELECT 'success' AS STATUS;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_USER_REGISTER_WITH_EMAIL` (IN `p_FIRSTNAME` VARCHAR(100) charset utf8, IN `p_LASTNAME` VARCHAR(100) charset utf8, IN `p_EMAIL` VARCHAR(150) charset utf8, IN `p_GENDER` TINYINT(4), IN `p_AGE` VARCHAR(10) charset utf8, IN `p_CITY_ID` INT UNSIGNED, IN `p_STATE_ID` INT UNSIGNED, IN `p_PASSWORD_HASH` VARCHAR(100) charset utf8, IN `p_VERIFY_CODE` CHAR(8), IN `p_REGISTER_IP` VARCHAR(15))   BEGIN
	IF NOT EXISTS (SELECT ID FROM tb_user WHERE EMAIL = p_EMAIL) THEN
		INSERT INTO tb_user (
			FIRSTNAME,
            LASTNAME,
            EMAIL,
            GENDER,
            AGE,
            CITY_ID,
            STATE_ID,
            PASSWORD_HASH,
            VERIFY_CODE,
            REGISTER_IP
        ) VALUES (
			p_FIRSTNAME,
            p_LASTNAME,
            p_EMAIL,
            p_GENDER,
            p_AGE,
            p_CITY_ID,
            p_STATE_ID,
            p_PASSWORD_HASH,
            p_VERIFY_CODE,
            p_REGISTER_IP
        );
        
        SELECT LAST_INSERT_ID() AS USER_ID;
        SELECT 'success' AS STATUS;
    ELSE
		SELECT 'email-already' AS STATUS;
    END IF;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_USER_REGISTER_WITH_FACEBOOK` (IN `p_FIRSTNAME` VARCHAR(100) charset utf8, IN `p_LASTNAME` VARCHAR(100) charset utf8, IN `p_EMAIL` VARCHAR(150) charset utf8, IN `p_REGISTER_IP` VARCHAR(15) charset utf8, IN `p_FACEBOOK_ID` VARCHAR(100) charset utf8)   BEGIN
	INSERT INTO tb_user (
		FACEBOOK_ID,
		FIRSTNAME,
        LASTNAME,
        EMAIL,
        VERIFIED,
        REGISTER_IP
    ) VALUES (
		p_FACEBOOK_ID,
		p_FIRSTNAME,
        p_LASTNAME,
        p_EMAIL,
        TRUE,
        p_REGISTER_IP
    );
    
    SELECT LAST_INSERT_ID() AS USER_ID;
	SELECT 'success' AS STATUS;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_USER_REGISTER_WITH_GOOGLE` (IN `p_FIRSTNAME` VARCHAR(100) charset utf8, IN `p_LASTNAME` VARCHAR(100) charset utf8, IN `p_EMAIL` VARCHAR(150) charset utf8, IN `p_REGISTER_IP` VARCHAR(15) charset utf8)   BEGIN
	INSERT INTO tb_user (
		FIRSTNAME,
        LASTNAME,
        EMAIL,
        VERIFIED,
        REGISTER_IP
    ) VALUES (
		p_FIRSTNAME,
        p_LASTNAME,
        p_EMAIL,
        TRUE,
        p_REGISTER_IP
    );
    
    SELECT LAST_INSERT_ID() AS USER_ID;
	SELECT 'success' AS STATUS;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_USER_SUB_ACCOUNT_CREATE` (IN `p_USER_ID` INT UNSIGNED, IN `p_FIRSTNAME` VARCHAR(100) charset utf8, IN `p_LASTNAME` VARCHAR(100) charset utf8, IN `p_GENDER` TINYINT(4), IN `p_AGE` VARCHAR(10) charset utf8, IN `p_CITY_ID` INT UNSIGNED, IN `p_STATE_ID` INT UNSIGNED, IN `p_REGISTER_IP` VARCHAR(15))   BEGIN
	INSERT INTO tb_user (
		FIRSTNAME,
		LASTNAME,
		GENDER,
		AGE,
		CITY_ID,
		STATE_ID,
		REGISTER_IP
    ) VALUES (
		p_FIRSTNAME,
		p_LASTNAME,
        p_GENDER,
        p_AGE,
        p_CITY_ID,
        p_STATE_ID,
        p_REGISTER_IP
    );
    
    SET @SUB_USER_ID = (SELECT LAST_INSERT_ID());
    
    INSERT INTO tb_sub_user (
		SUB_USER_ID,
        CREATED_BY_USER_ID
    ) VALUES (
        @SUB_USER_ID,
        p_USER_ID
    );
    SELECT 'success' AS STATUS;
    SELECT @SUB_USER_ID AS SUB_USER_ID;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_USER_SUB_ACCOUNT_DELETE` (IN `p_USER_ID` INT UNSIGNED, IN `p_DELETED_ID` INT UNSIGNED)   BEGIN
	SET @MAIN_USER_ID = (SELECT CREATED_BY_USER_ID FROM tb_sub_user WHERE SUB_USER_ID = p_USER_ID OR CREATED_BY_USER_ID = p_USER_ID LIMIT 1);
    
    IF EXISTS (SELECT ID FROM tb_sub_user WHERE SUB_USER_ID = p_DELETED_ID AND CREATED_BY_USER_ID = @MAIN_USER_ID) THEN
		SET SQL_SAFE_UPDATES = 0;
			DELETE FROM tb_sub_user WHERE SUB_USER_ID = p_DELETED_ID AND CREATED_BY_USER_ID = @MAIN_USER_ID;
			DELETE FROM tb_user WHERE ID = p_DELETED_ID;
            DELETE FROM tb_list_used_by_user WHERE USER_ID = p_DELETED_ID;
            DELETE FROM tb_user_variable WHERE USER_ID = p_DELETED_ID;
        SET SQL_SAFE_UPDATES = 1;
        SELECT 'success' AS STATUS;
    ELSE
		SELECT 'error' AS STATUS;
    END IF;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_USER_SUB_ACCOUNT_LIST` (IN `p_USER_ID` INT UNSIGNED)   BEGIN
	SET @MAIN_USER_ID = (SELECT CREATED_BY_USER_ID FROM tb_sub_user WHERE SUB_USER_ID = p_USER_ID OR CREATED_BY_USER_ID = p_USER_ID LIMIT 1);
	SELECT 
		su.SUB_USER_ID, 
		u.FIRSTNAME AS SUB_FIRSTNAME,
		u.LASTNAME AS SUB_LASTNAME,
		date_format(u.CREATED_DATE, '%d/%m/%Y') AS SUB_CREATED_DATE,
		su.CREATED_BY_USER_ID AS MAIN_USER_ID,
		u2.FIRSTNAME AS MAIN_FIRSTNAME,
		u2.LASTNAME AS MAIN_LASTNAME,
		date_format(u2.CREATED_DATE, '%d/%m/%Y') AS MAIN_CREATED_DATE
	FROM 
		tb_sub_user su
	INNER JOIN
		tb_user u
	ON 
		su.SUB_USER_ID = u.ID
	INNER JOIN
		tb_user u2
	On
		su.CREATED_BY_USER_ID = u2.ID
	WHERE 
		CREATED_BY_USER_ID = @MAIN_USER_ID;
END$$

CREATE DEFINER=`admin`@`localhost` PROCEDURE `sp_USER_VERIFY_ACCOUNT` (IN `p_USER_ID` INT UNSIGNED, IN `p_VERIFY_CODE` CHAR(8) charset utf8)   BEGIN
	IF EXISTS (SELECT ID FROM tb_user WHERE ID = p_USER_ID AND VERIFY_CODE = p_VERIFY_CODE AND VERIFIED = FALSE) THEN
		SET SQL_SAFE_UPDATES = 0;
			UPDATE tb_user SET VERIFY_CODE = NULL, VERIFIED = TRUE WHERE ID = p_USER_ID;
        SET SQL_SAFE_UPDATES = 1;
        SELECT 'success' AS STATUS;
    ELSE
		SELECT 'invalid-code' AS STATUS;
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_app_about`
--

CREATE TABLE `tb_app_about` (
  `TERMS` text DEFAULT NULL,
  `PRIVACY` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Tablo döküm verisi `tb_app_about`
--

INSERT INTO `tb_app_about` (`TERMS`, `PRIVACY`) VALUES
('<p><strong>Giriş</strong></p><p>FULLBODYGYM\'\'e hoş geldiniz.</p><p>Bugün, uzmanlardan oluşan bir grup tarafından özellikle sizin için geliştirilmiş olan yepyeni bir uygulamayı sunuyoruz. Bodygym kısa süre içerisinde mükemmel sonuçlar elde etmenize yardımcı olacak. Vücudunuzu arzu ettiğiniz gibi şekillendirin. Bu uygulama size mümkün olan en iyi sonucu sağlamaya yardımcı olmak için bir dizi egzersiz ve onların ayrıntılı bilgilerini içerir.</p><p><strong>Kullanım Koşulları</strong></p><p>FULLBODYGYM\'\'e üye olup kullanarak işbu Kullanım Koşulları’nı, Gizlilik Politikası’nı ve kişisel verilerin korunmasına ilişkin metni bir bütün olarak kabul etmiş olursunuz.</p><p>Bu uygulamada yer alan dosyaların bir kısmı doğrudan ziyaretçilerimizin kendileri tarafından, sitede yayınlanmaları için kaydedilmiştir. Diğer dosyalar ise sadece bilgi vermek amacıyla iyi niyetle sunulmaktadır.</p><p>Bu site kapsamında 18 yaşından küçükler veli ve/veya vasinin izin ve/veya onayı olmaksızın alım-satım işlemlerinin tarafı olamazlar.</p><p>FULLBODYGYM\'\'i kullanırken yürürlükteki mevzuatı ihlal etmeyeceğini,</p><p>FULLBODYGYM\'\'de yayınlanan hiçbir içeriği derslig.com’dan izin almadan ticari amaçla olsun veya olmasın kullanmayacağını; editörler tarafından üretilen her neviden içerikleri başka internet sitelerinde, ortamlarda ve diğer mecralarda sahibinin adı ve bağlantı (link) belirtmeksizin yayınlayamayacağını, FULLBODYGYM markalarının tescilli markalar olduğunu ve izinsiz kullanılamayacağını,</p><p>Herhangi bir yazılım, donanım veya iletişim unsuruna zarar vermek, işlevini aksatmak maksadıyla virüs içeren yazılım veya başka bir bilgisayar kodu, dosyası oluşturmayacağını, yetkisi olmayan herhangi bir sisteme ve/veya veriye ulaşmaya çalışmayacağını,</p><p>Ayrıca direkt veya dolaylı olarak, verilen hizmetlerdeki algoritmaları ve kodları deşifre edecek, işlevlerini bozacak davranışlarda bulunmayacağını, İçerikleri değiştirme, dönüştürme, çevirme, alıntı göstermeksizin başka sitelerde yayınlama gibi davranışlarda bulunmayacağını,</p><p>FULLBODYGYM.xyz adresinde yayınlanan içeriklerin paylaşılması sebebiyle doğacak olan tüm hukuki sorumluluğun paylaşan kişiye ait olduğunu, derslig.com’un hiçbir sorumluluğunun olmadığını,</p><p>Derslig.com birçok içeriğinden başka sitelere bağlantı (link) verilebileceği kabulü ile FULLBODYGYM.xyz tarafından bağlantı (link) verilen, tavsiye edilen diğer sitelerin bilgi kullanımı, gizlilik ilkeleri ve içeriğinden FULLBODYGYM\'\'in sorumlu olmadığını,</p><p>FULLBODYGYM\'\'in kendi ürettiği veya dışardan aldığı bilgi, belge, yazılım, tasarım, grafik vb. eserlerin 5846 Sayılı Fikir ve Sanat Eserleri Kanunu kapsamında korunduğunu ve eser hakkının ihlali halinde bundan dolayı sorumlu olunacağını,</p><p>5846 sayılı kanunun 25. maddesinin ek 4. maddesine göre hakkı ihlal edilen öncelikle üç gün içinde ihlalin durdurulmasını istemek zorunda olduğunu,</p><p>FULLBODYGYM\'\'in kullanıcı üyeliği gerektirmeyen hizmetleri zaman içinde üyelik gerektiren bir hale dönüştürebileceğini, ilave hizmetler açabileceğini, bazı hizmetlerini kısmen veya tamamen değiştirebileceği veya ücretli hale dönüştürebileceğini,</p><p>Kullanıcının içerik oluşturmasına izin verilen yorumlarda ya da forumlarda ya da diğer platformlarda içerik oluşturan kişilerin bu içerikten dolayı tamamen ve tek başına sorumlu olduğunu,</p><p>FULLBODYGYM\'\'in içerik oluşturan kullanıcı ile ilgili kısıtlama ve kullanıcı engelleme, silme hakkına sahip olduğunu,</p><p>FULLBODYGYM\'\'deki bilgilerin güncelliği, doğruluğu, şartları, kalitesi, performansı, pazarlanabilirliği, belli bir amaca uygunluğu ve diğer bilgi, hizmet veya ürünlere etkisi ile tamlığı ve/veya kesintisiz devamlılık, güncelleme, işlevsellik, doğruluk, hatasızlık hakkında herhangi bir şekilde, FULLBODYGYM tarafından açık ya da zımni olarak garanti verilmediğini ve taahhütte bulunulmadığını,</p><p>FULLBODYGYM\'\'in gerekli gördüğü zamanlarda hizmetleri geçici bir süre askıya alabileceğini veya tamamen durdurabileceğini, hizmetlerin geçici bir süre askıya alınması veya tamamen durdurulmasından dolayı kullanıcılara karşı herhangi bir sorumluluğunun olmadığını,</p><p>FULLBODYGYM\'\'in hizmetleri, tasarımı ve içeriği her zaman değiştirebilme veya silebilme hakkını saklı tuttuğunu ve sunulan hizmetlerin kullanıcılara kazanılmış hak tahsis etmeyeceğini,</p><p>İçerik yükleyici, üye, kullanıcı, ziyaretçi veya antrenör diğer kişiler tarafından FULLBODYGYM\'\'e yüklenilen her türlü bilgi, belge, içerik, yorum veya veriler arasında Türkiye Cumhuriyeti Devleti’nin gizli tutulması gereken bilgilerinden olan, Türkiye Cumhuriyeti Devleti’nin bekasına zarar verebilecek içeriklerden olan, ticaret şirketleri ve sair tüzel kişilerin ticari sırrı niteliğinde olan, üçüncü kişilerin kişilik haklarını zedeleyen, çıplaklık, müstehcenlik veya cinsellik içeren, diğer kullanıcıları, bir toplumu, ırkı veya topluluğu hedef alan tehdit veya taciz yahut nefret içerikli olan, herhangi bir siyasi ideoloji veya propaganda içerikli olan, herhangi bir sebeple de olsa örgütlenme mesajı taşıyan her türlü bilgi, belge, içerik, yorum veya verilerin bulunması durumunda FULLBODYGYM\'\'in hukuki ve/veya cezai sorumluluğunun olmadığını, bu konudaki sorumluluğun ilgili bilgi, belge, içerik, yorum veya veriyi gönderen kullanıcıda olduğunu,</p><p>Uygulamanın kullanımı sırasında her ne sebeple olursa olsun ortaya çıkan her türlü zarar, ziyan ve masraftan FULLBODYGYM\'\'in sorumlu olmayacağını,</p><p>FULLBODYGYM\'\'in kullanım koşulları ve kuralları her zaman tek taraflı değiştirme hakkının saklı olduğunu ve bu kapsamda, işbu Kullanım Koşulları’nın, Gizlilik Politikası’nın ve Kişisel Verilerin Korunmasına İlişkin Aydınlatma Metni’nin tamamını okuduğunu ve bir bütün olarak onayladığını, FULLBODYGYM\'\'a mümkün olan tüm mecralar vasıtası ile ulaşarak ayrıca onay gerekmeksizin belirtilen tüm metinleri ve de metinlerde belirtilen kural ve koşulları bir bütün olarak kabul, beyan ve taahhüt eder.</p>', '<p>FULLBODYGYM uygulaması içerisinde gezindiğiniz süre boyunca \'cookie\' olarak adlandırılan ve Türkçe\'ye çerez olarak geçirilen bazı unsurların bilgisayarınıza entegre edilmesi söz konusu olabilir. Çerezler basit metin dosyalarıdır ve kişisel veri ya da başkaca özel veri içermemektedir. Web sitesi oturum bilgileri ve benzeri veriler saklar ve kullanıcıları tekrar tanımak için kullanır. Bu içeriğin güvenilirliğine ilişkin FULLBODYGYM\'in sorumluluğu bulunmamaktadır.</p><p>FULLBODYGYM, internet sitesine, haber ağına, herhangi bir listesine, sosyal ağına kaydolma/katılma sebebiyle veya kullanım süresince kullanıcıdan talep edilen veya sitenin/sosyal ağın kullanımı esnasında yapılan işlemlerin otomatik olarak kaydedilmesi yöntemleriyle toplanılan her türlü veriyi saklama, kullanma ve sair şekilde işleme hakkına sahiptir.</p><p>Veriler anonim hale getirilerek istatistiki veri olarak kullanılabilecek ve ancak Kişisel Verilerin Korunması Hakkında Kanun\'un izin verdiği şartlarda üçüncü kişilerle paylaşılabilecektir.</p><p>Yasal zorunluluğun söz konusu olması ve yetkili makamlar tarafından usulüne uygun olarak talep edilmesi halinde 5651 sayılı Kanun\'dan ve 6698 sayılı Kanun\'dan kaynaklanan hallerde bilgiler ilgili makamla paylaşılabilecektir. Kullanıcıların FULLBODYGYM\'e ait sosyal medya paylaşım alanları, web sitesi ve mesajlaşma ortamlarında belirtilen kurallara, yürürlükteki mevzuata ve de hukuka uygun davranması gerekmektedir.</p><p>Kullanım koşulları, Kişisel Verilerin Korunmasına İlişkin Aydınlatma Metni ve bu Gizlilik Politikası ayrılmaz bir bütündür.</p><p>Bu Gizlilik Politikası FULLBODYGYM tarafından önceden duyurulmaksızın ve tek taraflı olarak değiştirilebilir. Gizlilik Politikası metninde değişiklik yapılması halinde, metnin yeni hali FULLBODYGYM\'e yayınlandığı andan itibaren tüm kullanıcılar için geçerli olacaktır. Bu kapsamda, metindeki değişiklikleri takip etmek kullanıcıların yükümlülüğüdür.</p>');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_category`
--

CREATE TABLE `tb_category` (
  `ID` int(10) UNSIGNED NOT NULL,
  `CATEGORY_NAME` varchar(150) CHARACTER SET utf8 DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Tablo döküm verisi `tb_category`
--

INSERT INTO `tb_category` (`ID`, `CATEGORY_NAME`) VALUES
(1, 'Aikido'),
(2, 'Atletizm'),
(3, 'Basketbol'),
(4, 'Binicilik'),
(5, 'Bisiklet'),
(6, 'Boks'),
(7, 'Buz Hokeyi'),
(8, 'Fitness'),
(9, 'Futbol'),
(10, 'Güreş'),
(11, 'Hentbol'),
(12, 'Jimnastik'),
(13, 'Judo'),
(14, 'Kick Boks'),
(15, 'Maraton'),
(16, 'Okçuluk'),
(17, 'Parkour'),
(18, 'Tekvando'),
(19, 'Tenis'),
(20, 'Triatlon'),
(21, 'Voleybol'),
(22, 'Yağlı Güreş'),
(23, 'Yüzme');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_city`
--

CREATE TABLE `tb_city` (
  `ID` int(10) UNSIGNED NOT NULL,
  `NAME` varchar(150) CHARACTER SET utf8 DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Tablo döküm verisi `tb_city`
--

INSERT INTO `tb_city` (`ID`, `NAME`) VALUES
(1, 'Adana'),
(2, 'Adıyaman'),
(3, 'Afyonkarahisar'),
(4, 'Ağrı'),
(5, 'Amasya'),
(6, 'Ankara'),
(7, 'Antalya'),
(8, 'Artvin'),
(9, 'Aydın'),
(10, 'Balıkesir'),
(11, 'Bilecik'),
(12, 'Bingöl'),
(13, 'Bitlis'),
(14, 'Bolu'),
(15, 'Burdur'),
(16, 'Bursa'),
(17, 'Çanakkale'),
(18, 'Çankırı'),
(19, 'Çorum'),
(20, 'Denizli'),
(21, 'Diyarbakır'),
(22, 'Edirne'),
(23, 'Elazığ'),
(24, 'Erzincan'),
(25, 'Erzurum'),
(26, 'Eskişehir'),
(27, 'Gaziantep'),
(28, 'Giresun'),
(29, 'Gümüşhane'),
(30, 'Hakkari'),
(31, 'Hatay'),
(32, 'Isparta'),
(33, 'Mersin'),
(34, 'İstanbul'),
(35, 'İzmir'),
(36, 'Kars'),
(37, 'Kastamonu'),
(38, 'Kayseri'),
(39, 'Kırklareli'),
(40, 'Kırşehir'),
(41, 'Kocaeli'),
(42, 'Konya'),
(43, 'Kütahya'),
(44, 'Malatya'),
(45, 'Manisa'),
(46, 'Kahramanmaraş'),
(47, 'Mardin'),
(48, 'Muğla'),
(49, 'Muş'),
(50, 'Nevşehir'),
(51, 'Niğde'),
(52, 'Ordu'),
(53, 'Rize'),
(54, 'Sakarya'),
(55, 'Samsun'),
(56, 'Siirt'),
(57, 'Sinop'),
(58, 'Sivas'),
(59, 'Tekirdağ'),
(60, 'Tokat'),
(61, 'Trabzon'),
(62, 'Tunceli'),
(63, 'Şanlıurfa'),
(64, 'Uşak'),
(65, 'Van'),
(66, 'Yozgat'),
(67, 'Zonguldak'),
(68, 'Aksaray'),
(69, 'Bayburt'),
(70, 'Karaman'),
(71, 'Kırıkkale'),
(72, 'Batman'),
(73, 'Şırnak'),
(74, 'Bartın'),
(75, 'Ardahan'),
(76, 'Iğdır'),
(77, 'Yalova'),
(78, 'Karabük'),
(79, 'Kilis'),
(80, 'Osmaniye'),
(81, 'Düzce');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_coach`
--

CREATE TABLE `tb_coach` (
  `ID` int(10) UNSIGNED NOT NULL,
  `FACEBOOK_ID` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `FIRSTNAME` varchar(100) CHARACTER SET utf8 NOT NULL,
  `LASTNAME` varchar(100) CHARACTER SET utf8 NOT NULL,
  `EMAIL` varchar(150) CHARACTER SET utf8 DEFAULT NULL,
  `PASSWORD_HASH` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `VERIFIED` tinyint(1) NOT NULL DEFAULT 0,
  `VERIFY_CODE` char(8) CHARACTER SET utf8 DEFAULT NULL,
  `REGISTER_IP` varchar(15) CHARACTER SET utf8 NOT NULL,
  `REGISTER_DATE` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Tablo döküm verisi `tb_coach`
--


-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_coach_password_reset`
--

CREATE TABLE `tb_coach_password_reset` (
  `ID` int(10) UNSIGNED NOT NULL,
  `COACH_ID` int(10) UNSIGNED DEFAULT NULL,
  `RESET_CODE` varchar(6) CHARACTER SET utf8 DEFAULT NULL,
  `REQUEST_IP` varchar(15) CHARACTER SET utf8 NOT NULL,
  `REQUEST_DATE` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_list`
--

CREATE TABLE `tb_list` (
  `ID` int(10) UNSIGNED NOT NULL,
  `COACH_ID` int(10) UNSIGNED NOT NULL,
  `CATEGORY_ID` int(10) UNSIGNED DEFAULT NULL,
  `LIST_CODE` varchar(15) CHARACTER SET utf8 NOT NULL,
  `LIST_NAME` varchar(300) CHARACTER SET utf8 NOT NULL,
  `HALL_NAME` varchar(300) CHARACTER SET utf8 DEFAULT NULL,
  `GENDER` tinyint(4) DEFAULT NULL,
  `MEASURE_TYPE` varchar(4) NOT NULL,
  `WEIGHT_TYPE` varchar(3) NOT NULL,
  `CREATED_DATE` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Tablo döküm verisi `tb_list`
--

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_list_used_by_user`
--

CREATE TABLE `tb_list_used_by_user` (
  `ID` int(10) UNSIGNED NOT NULL,
  `USER_ID` int(10) UNSIGNED NOT NULL,
  `COACH_ID` int(10) UNSIGNED NOT NULL,
  `LIST_ID` int(10) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Tablo döküm verisi `tb_list_used_by_user`
--

INSERT INTO `tb_list_used_by_user` (`ID`, `USER_ID`, `COACH_ID`, `LIST_ID`) VALUES
(2, 2, 1, NULL),
(4, 4, 19, NULL),
(5, 5, 19, NULL),
(9, 3, 1, 1),
(12, 1, 1, 1),
(13, 7, 1, 1),
(14, 1, 1, 6),
(15, 3, 1, 7);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_list_variable`
--

CREATE TABLE `tb_list_variable` (
  `ID` int(10) UNSIGNED NOT NULL,
  `LIST_ID` int(10) UNSIGNED NOT NULL,
  `VARIABLE_ID` int(10) UNSIGNED NOT NULL,
  `VARIABLE_VALUE` varchar(100) CHARACTER SET utf8 DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Tablo döküm verisi `tb_list_variable`
--

INSERT INTO `tb_list_variable` (`ID`, `LIST_ID`, `VARIABLE_ID`, `VARIABLE_VALUE`) VALUES
(1, 1, 1, '505'),
(2, 1, 2, '5'),
(3, 1, 3, '5'),
(4, 1, 4, '7'),
(5, 1, 5, '7'),
(6, 1, 22, '30'),
(7, 1, 23, '50'),
(11, 3, 1, '100'),
(12, 3, 2, ''),
(13, 3, 4, '35'),
(14, 3, 10, '39'),
(15, 3, 13, '39'),
(16, 3, 15, '105.2'),
(17, 3, 17, '98.7'),
(18, 3, 18, '107.23'),
(19, 4, 1, '102'),
(20, 4, 8, '96'),
(21, 4, 15, '101.2'),
(22, 4, 17, '107.29'),
(23, 4, 19, '58'),
(24, 4, 21, '58'),
(25, 5, 1, '5051'),
(26, 6, 1, '50'),
(27, 6, 2, '120'),
(28, 7, 2, '20');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_state`
--

CREATE TABLE `tb_state` (
  `ID` int(10) UNSIGNED NOT NULL,
  `NAME` varchar(150) CHARACTER SET utf8 DEFAULT NULL,
  `CITY_ID` int(10) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Tablo döküm verisi `tb_state`
--

INSERT INTO `tb_state` (`ID`, `NAME`, `CITY_ID`) VALUES
(1, 'Seyhan', 1),
(2, 'Ceyhan', 1),
(3, 'Feke', 1),
(4, 'Karaisalı', 1),
(5, 'Karataş', 1),
(6, 'Kozan', 1),
(7, 'Pozantı', 1),
(8, 'Saimbeyli', 1),
(9, 'Tufanbeyli', 1),
(10, 'Yumurtalık', 1),
(11, 'Yüreğir', 1),
(12, 'Aladağ', 1),
(13, 'İmamoğlu', 1),
(14, 'Sarıçam', 1),
(15, 'Çukurova', 1),
(16, 'Adıyaman Merkez', 2),
(17, 'Besni', 2),
(18, 'Çelikhan', 2),
(19, 'Gerger', 2),
(20, 'Gölbaşı / Adıyaman', 2),
(21, 'Kahta', 2),
(22, 'Samsat', 2),
(23, 'Sincik', 2),
(24, 'Tut', 2),
(25, 'Afyonkarahisar Merkez', 3),
(26, 'Bolvadin', 3),
(27, 'Çay', 3),
(28, 'Dazkırı', 3),
(29, 'Dinar', 3),
(30, 'Emirdağ', 3),
(31, 'İhsaniye', 3),
(32, 'Sandıklı', 3),
(33, 'Sinanpaşa', 3),
(34, 'Sultandağı', 3),
(35, 'Şuhut', 3),
(36, 'Başmakçı', 3),
(37, 'Bayat / Afyonkarahisar', 3),
(38, 'İscehisar', 3),
(39, 'Çobanlar', 3),
(40, 'Evciler', 3),
(41, 'Hocalar', 3),
(42, 'Kızılören', 3),
(43, 'Ağrı Merkez', 4),
(44, 'Diyadin', 4),
(45, 'Doğubayazıt', 4),
(46, 'Eleşkirt', 4),
(47, 'Hamur', 4),
(48, 'Patnos', 4),
(49, 'Taşlıçay', 4),
(50, 'Tutak', 4),
(51, 'Amasya Merkez', 5),
(52, 'Göynücek', 5),
(53, 'Gümüşhacıköy', 5),
(54, 'Merzifon', 5),
(55, 'Suluova', 5),
(56, 'Taşova', 5),
(57, 'Hamamözü', 5),
(58, 'Altındağ', 6),
(59, 'Ayaş', 6),
(60, 'Bala', 6),
(61, 'Beypazarı', 6),
(62, 'Çamlıdere', 6),
(63, 'Çankaya', 6),
(64, 'Çubuk', 6),
(65, 'Elmadağ', 6),
(66, 'Güdül', 6),
(67, 'Haymana', 6),
(68, 'Kalecik', 6),
(69, 'Kızılcahamam', 6),
(70, 'Nallıhan', 6),
(71, 'Polatlı', 6),
(72, 'Şereflikoçhisar', 6),
(73, 'Yenimahalle', 6),
(74, 'Gölbaşı / Ankara', 6),
(75, 'Keçiören', 6),
(76, 'Mamak', 6),
(77, 'Sincan', 6),
(78, 'Kazan', 6),
(79, 'Akyurt', 6),
(80, 'Etimesgut', 6),
(81, 'Evren', 6),
(82, 'Pursaklar', 6),
(83, 'Akseki', 7),
(84, 'Alanya', 7),
(85, 'Elmalı', 7),
(86, 'Finike', 7),
(87, 'Gazipaşa', 7),
(88, 'Gündoğmuş', 7),
(89, 'Kaş', 7),
(90, 'Korkuteli', 7),
(91, 'Kumluca', 7),
(92, 'Manavgat', 7),
(93, 'Serik', 7),
(94, 'Demre', 7),
(95, 'İbradı', 7),
(96, 'Kemer / Antalya', 7),
(97, 'Aksu / Antalya', 7),
(98, 'Döşemealtı', 7),
(99, 'Kepez', 7),
(100, 'Konyaaltı', 7),
(101, 'Muratpaşa', 7),
(102, 'Ardanuç', 8),
(103, 'Arhavi', 8),
(104, 'Artvin Merkez', 8),
(105, 'Borçka', 8),
(106, 'Hopa', 8),
(107, 'Şavşat', 8),
(108, 'Yusufeli', 8),
(109, 'Murgul', 8),
(110, 'Bozdoğan', 9),
(111, 'Çine', 9),
(112, 'Germencik', 9),
(113, 'Karacasu', 9),
(114, 'Koçarlı', 9),
(115, 'Kuşadası', 9),
(116, 'Kuyucak', 9),
(117, 'Nazilli', 9),
(118, 'Söke', 9),
(119, 'Sultanhisar', 9),
(120, 'Yenipazar / Aydın', 9),
(121, 'Buharkent', 9),
(122, 'İncirliova', 9),
(123, 'Karpuzlu', 9),
(124, 'Köşk', 9),
(125, 'Didim', 9),
(126, 'Efeler', 9),
(127, 'Ayvalık', 10),
(128, 'Balya', 10),
(129, 'Bandırma', 10),
(130, 'Bigadiç', 10),
(131, 'Burhaniye', 10),
(132, 'Dursunbey', 10),
(133, 'Edremit / Balıkesir', 10),
(134, 'Erdek', 10),
(135, 'Gönen / Balıkesir', 10),
(136, 'Havran', 10),
(137, 'İvrindi', 10),
(138, 'Kepsut', 10),
(139, 'Manyas', 10),
(140, 'Savaştepe', 10),
(141, 'Sındırgı', 10),
(142, 'Susurluk', 10),
(143, 'Marmara', 10),
(144, 'Gömeç', 10),
(145, 'Altıeylül', 10),
(146, 'Karesi', 10),
(147, 'Bilecik Merkez', 11),
(148, 'Bozüyük', 11),
(149, 'Gölpazarı', 11),
(150, 'Osmaneli', 11),
(151, 'Pazaryeri', 11),
(152, 'Söğüt', 11),
(153, 'Yenipazar / Bilecik', 11),
(154, 'İnhisar', 11),
(155, 'Bingöl Merkez', 12),
(156, 'Genç', 12),
(157, 'Karlıova', 12),
(158, 'Kiğı', 12),
(159, 'Solhan', 12),
(160, 'Adaklı', 12),
(161, 'Yayladere', 12),
(162, 'Yedisu', 12),
(163, 'Adilcevaz', 13),
(164, 'Ahlat', 13),
(165, 'Bitlis Merkez', 13),
(166, 'Hizan', 13),
(167, 'Mutki', 13),
(168, 'Tatvan', 13),
(169, 'Güroymak', 13),
(170, 'Bolu Merkez', 14),
(171, 'Gerede', 14),
(172, 'Göynük', 14),
(173, 'Kıbrıscık', 14),
(174, 'Mengen', 14),
(175, 'Mudurnu', 14),
(176, 'Seben', 14),
(177, 'Dörtdivan', 14),
(178, 'Yeniçağa', 14),
(179, 'Ağlasun', 15),
(180, 'Bucak', 15),
(181, 'Burdur Merkez', 15),
(182, 'Gölhisar', 15),
(183, 'Tefenni', 15),
(184, 'Yeşilova', 15),
(185, 'Karamanlı', 15),
(186, 'Kemer / Burdur', 15),
(187, 'Altınyayla / Burdur', 15),
(188, 'Çavdır', 15),
(189, 'Çeltikçi', 15),
(190, 'Gemlik', 16),
(191, 'İnegöl', 16),
(192, 'İznik', 16),
(193, 'Karacabey', 16),
(194, 'Keles', 16),
(195, 'Mudanya', 16),
(196, 'Mustafakemalpaşa', 16),
(197, 'Orhaneli', 16),
(198, 'Orhangazi', 16),
(199, 'Yenişehir / Bursa', 16),
(200, 'Büyükorhan', 16),
(201, 'Harmancık', 16),
(202, 'Nilüfer', 16),
(203, 'Osmangazi', 16),
(204, 'Yıldırım', 16),
(205, 'Gürsu', 16),
(206, 'Kestel', 16),
(207, 'Ayvacık / Çanakkale', 17),
(208, 'Bayramiç', 17),
(209, 'Biga', 17),
(210, 'Bozcaada', 17),
(211, 'Çan', 17),
(212, 'Çanakkale Merkez', 17),
(213, 'Eceabat', 17),
(214, 'Ezine', 17),
(215, 'Gelibolu', 17),
(216, 'Gökçeada', 17),
(217, 'Lapseki', 17),
(218, 'Yenice / Çanakkale', 17),
(219, 'Çankırı Merkez', 18),
(220, 'Çerkeş', 18),
(221, 'Eldivan', 18),
(222, 'Ilgaz', 18),
(223, 'Kurşunlu', 18),
(224, 'Orta', 18),
(225, 'Şabanözü', 18),
(226, 'Yapraklı', 18),
(227, 'Atkaracalar', 18),
(228, 'Kızılırmak', 18),
(229, 'Bayramören', 18),
(230, 'Korgun', 18),
(231, 'Alaca', 19),
(232, 'Bayat / Çorum', 19),
(233, 'Çorum Merkez', 19),
(234, 'İskilip', 19),
(235, 'Kargı', 19),
(236, 'Mecitözü', 19),
(237, 'Ortaköy / Çorum', 19),
(238, 'Osmancık', 19),
(239, 'Sungurlu', 19),
(240, 'Boğazkale', 19),
(241, 'Uğurludağ', 19),
(242, 'Dodurga', 19),
(243, 'Laçin', 19),
(244, 'Oğuzlar', 19),
(245, 'Acıpayam', 20),
(246, 'Buldan', 20),
(247, 'Çal', 20),
(248, 'Çameli', 20),
(249, 'Çardak', 20),
(250, 'Çivril', 20),
(251, 'Güney', 20),
(252, 'Kale / Denizli', 20),
(253, 'Sarayköy', 20),
(254, 'Tavas', 20),
(255, 'Babadağ', 20),
(256, 'Bekilli', 20),
(257, 'Honaz', 20),
(258, 'Serinhisar', 20),
(259, 'Pamukkale', 20),
(260, 'Baklan', 20),
(261, 'Beyağaç', 20),
(262, 'Bozkurt / Denizli', 20),
(263, 'Merkezefendi', 20),
(264, 'Bismil', 21),
(265, 'Çermik', 21),
(266, 'Çınar', 21),
(267, 'Çüngüş', 21),
(268, 'Dicle', 21),
(269, 'Ergani', 21),
(270, 'Hani', 21),
(271, 'Hazro', 21),
(272, 'Kulp', 21),
(273, 'Lice', 21),
(274, 'Silvan', 21),
(275, 'Eğil', 21),
(276, 'Kocaköy', 21),
(277, 'Bağlar', 21),
(278, 'Kayapınar', 21),
(279, 'Sur', 21),
(280, 'Yenişehir / Diyarbakır', 21),
(281, 'Edirne Merkez', 22),
(282, 'Enez', 22),
(283, 'Havsa', 22),
(284, 'İpsala', 22),
(285, 'Keşan', 22),
(286, 'Lalapaşa', 22),
(287, 'Meriç', 22),
(288, 'Uzunköprü', 22),
(289, 'Süloğlu', 22),
(290, 'Ağın', 23),
(291, 'Baskil', 23),
(292, 'Elazığ Merkez', 23),
(293, 'Karakoçan', 23),
(294, 'Keban', 23),
(295, 'Maden', 23),
(296, 'Palu', 23),
(297, 'Sivrice', 23),
(298, 'Arıcak', 23),
(299, 'Kovancılar', 23),
(300, 'Alacakaya', 23),
(301, 'Çayırlı', 24),
(302, 'Erzincan Merkez', 24),
(303, 'İliç', 24),
(304, 'Kemah', 24),
(305, 'Kemaliye', 24),
(306, 'Refahiye', 24),
(307, 'Tercan', 24),
(308, 'Üzümlü', 24),
(309, 'Otlukbeli', 24),
(310, 'Aşkale', 25),
(311, 'Çat', 25),
(312, 'Hınıs', 25),
(313, 'Horasan', 25),
(314, 'İspir', 25),
(315, 'Karayazı', 25),
(316, 'Narman', 25),
(317, 'Oltu', 25),
(318, 'Olur', 25),
(319, 'Pasinler', 25),
(320, 'Şenkaya', 25),
(321, 'Tekman', 25),
(322, 'Tortum', 25),
(323, 'Karaçoban', 25),
(324, 'Uzundere', 25),
(325, 'Pazaryolu', 25),
(326, 'Aziziye', 25),
(327, 'Köprüköy', 25),
(328, 'Palandöken', 25),
(329, 'Yakutiye', 25),
(330, 'Çifteler', 26),
(331, 'Mahmudiye', 26),
(332, 'Mihalıççık', 26),
(333, 'Sarıcakaya', 26),
(334, 'Seyitgazi', 26),
(335, 'Sivrihisar', 26),
(336, 'Alpu', 26),
(337, 'Beylikova', 26),
(338, 'İnönü', 26),
(339, 'Günyüzü', 26),
(340, 'Han', 26),
(341, 'Mihalgazi', 26),
(342, 'Odunpazarı', 26),
(343, 'Tepebaşı', 26),
(344, 'Araban', 27),
(345, 'İslahiye', 27),
(346, 'Nizip', 27),
(347, 'Oğuzeli', 27),
(348, 'Yavuzeli', 27),
(349, 'Şahinbey', 27),
(350, 'Şehitkamil', 27),
(351, 'Karkamış', 27),
(352, 'Nurdağı', 27),
(353, 'Alucra', 28),
(354, 'Bulancak', 28),
(355, 'Dereli', 28),
(356, 'Espiye', 28),
(357, 'Eynesil', 28),
(358, 'Giresun Merkez', 28),
(359, 'Görele', 28),
(360, 'Keşap', 28),
(361, 'Şebinkarahisar', 28),
(362, 'Tirebolu', 28),
(363, 'Piraziz', 28),
(364, 'Yağlıdere', 28),
(365, 'Çamoluk', 28),
(366, 'Çanakçı', 28),
(367, 'Doğankent', 28),
(368, 'Güce', 28),
(369, 'Gümüşhane Merkez', 29),
(370, 'Kelkit', 29),
(371, 'Şiran', 29),
(372, 'Torul', 29),
(373, 'Köse', 29),
(374, 'Kürtün', 29),
(375, 'Çukurca', 30),
(376, 'Hakkari Merkez', 30),
(377, 'Şemdinli', 30),
(378, 'Yüksekova', 30),
(379, 'Altınözü', 31),
(380, 'Dörtyol', 31),
(381, 'Hassa', 31),
(382, 'İskenderun', 31),
(383, 'Kırıkhan', 31),
(384, 'Reyhanlı', 31),
(385, 'Samandağ', 31),
(386, 'Yayladağı', 31),
(387, 'Erzin', 31),
(388, 'Belen', 31),
(389, 'Kumlu', 31),
(390, 'Antakya', 31),
(391, 'Arsuz', 31),
(392, 'Defne', 31),
(393, 'Payas', 31),
(394, 'Atabey', 32),
(395, 'Eğirdir', 32),
(396, 'Gelendost', 32),
(397, 'Isparta Merkez', 32),
(398, 'Keçiborlu', 32),
(399, 'Senirkent', 32),
(400, 'Sütçüler', 32),
(401, 'Şarkikaraağaç', 32),
(402, 'Uluborlu', 32),
(403, 'Yalvaç', 32),
(404, 'Aksu / Isparta', 32),
(405, 'Gönen / Isparta', 32),
(406, 'Yenişarbademli', 32),
(407, 'Anamur', 33),
(408, 'Erdemli', 33),
(409, 'Gülnar', 33),
(410, 'Mut', 33),
(411, 'Silifke', 33),
(412, 'Tarsus', 33),
(413, 'Aydıncık / Mersin', 33),
(414, 'Bozyazı', 33),
(415, 'Çamlıyayla', 33),
(416, 'Akdeniz', 33),
(417, 'Mezitli', 33),
(418, 'Toroslar', 33),
(419, 'Yenişehir / Mersin', 33),
(420, 'Adalar', 34),
(421, 'Bakırköy', 34),
(422, 'Beşiktaş', 34),
(423, 'Beykoz', 34),
(424, 'Beyoğlu', 34),
(425, 'Çatalca', 34),
(426, 'Eyüp', 34),
(427, 'Fatih', 34),
(428, 'Gaziosmanpaşa', 34),
(429, 'Kadıköy', 34),
(430, 'Kartal', 34),
(431, 'Sarıyer', 34),
(432, 'Silivri', 34),
(433, 'Şile', 34),
(434, 'Şişli', 34),
(435, 'Üsküdar', 34),
(436, 'Zeytinburnu', 34),
(437, 'Büyükçekmece', 34),
(438, 'Kağıthane', 34),
(439, 'Küçükçekmece', 34),
(440, 'Pendik', 34),
(441, 'Ümraniye', 34),
(442, 'Bayrampaşa', 34),
(443, 'Avcılar', 34),
(444, 'Bağcılar', 34),
(445, 'Bahçelievler', 34),
(446, 'Güngören', 34),
(447, 'Maltepe', 34),
(448, 'Sultanbeyli', 34),
(449, 'Tuzla', 34),
(450, 'Esenler', 34),
(451, 'Arnavutköy', 34),
(452, 'Ataşehir', 34),
(453, 'Başakşehir', 34),
(454, 'Beylikdüzü', 34),
(455, 'Çekmeköy', 34),
(456, 'Esenyurt', 34),
(457, 'Sancaktepe', 34),
(458, 'Sultangazi', 34),
(459, 'Aliağa', 35),
(460, 'Bayındır', 35),
(461, 'Bergama', 35),
(462, 'Bornova', 35),
(463, 'Çeşme', 35),
(464, 'Dikili', 35),
(465, 'Foça', 35),
(466, 'Karaburun', 35),
(467, 'Karşıyaka', 35),
(468, 'Kemalpaşa / İzmir', 35),
(469, 'Kınık', 35),
(470, 'Kiraz', 35),
(471, 'Menemen', 35),
(472, 'Ödemiş', 35),
(473, 'Seferihisar', 35),
(474, 'Selçuk', 35),
(475, 'Tire', 35),
(476, 'Torbalı', 35),
(477, 'Urla', 35),
(478, 'Beydağ', 35),
(479, 'Buca', 35),
(480, 'Konak', 35),
(481, 'Menderes', 35),
(482, 'Balçova', 35),
(483, 'Çiğli', 35),
(484, 'Gaziemir', 35),
(485, 'Narlıdere', 35),
(486, 'Güzelbahçe', 35),
(487, 'Bayraklı', 35),
(488, 'Karabağlar', 35),
(489, 'Arpaçay', 36),
(490, 'Digor', 36),
(491, 'Kağızman', 36),
(492, 'Kars Merkez', 36),
(493, 'Sarıkamış', 36),
(494, 'Selim', 36),
(495, 'Susuz', 36),
(496, 'Akyaka', 36),
(497, 'Abana', 37),
(498, 'Araç', 37),
(499, 'Azdavay', 37),
(500, 'Bozkurt / Kastamonu', 37),
(501, 'Cide', 37),
(502, 'Çatalzeytin', 37),
(503, 'Daday', 37),
(504, 'Devrekani', 37),
(505, 'İnebolu', 37),
(506, 'Kastamonu Merkez', 37),
(507, 'Küre', 37),
(508, 'Taşköprü', 37),
(509, 'Tosya', 37),
(510, 'İhsangazi', 37),
(511, 'Pınarbaşı / Kastamonu', 37),
(512, 'Şenpazar', 37),
(513, 'Ağlı', 37),
(514, 'Doğanyurt', 37),
(515, 'Hanönü', 37),
(516, 'Seydiler', 37),
(517, 'Bünyan', 38),
(518, 'Develi', 38),
(519, 'Felahiye', 38),
(520, 'İncesu', 38),
(521, 'Pınarbaşı / Kayseri', 38),
(522, 'Sarıoğlan', 38),
(523, 'Sarız', 38),
(524, 'Tomarza', 38),
(525, 'Yahyalı', 38),
(526, 'Yeşilhisar', 38),
(527, 'Akkışla', 38),
(528, 'Talas', 38),
(529, 'Kocasinan', 38),
(530, 'Melikgazi', 38),
(531, 'Hacılar', 38),
(532, 'Özvatan', 38),
(533, 'Babaeski', 39),
(534, 'Demirköy', 39),
(535, 'Kırklareli Merkez', 39),
(536, 'Kofçaz', 39),
(537, 'Lüleburgaz', 39),
(538, 'Pehlivanköy', 39),
(539, 'Pınarhisar', 39),
(540, 'Vize', 39),
(541, 'Çiçekdağı', 40),
(542, 'Kaman', 40),
(543, 'Kırşehir Merkez', 40),
(544, 'Mucur', 40),
(545, 'Akpınar', 40),
(546, 'Akçakent', 40),
(547, 'Boztepe', 40),
(548, 'Gebze', 41),
(549, 'Gölcük', 41),
(550, 'Kandıra', 41),
(551, 'Karamürsel', 41),
(552, 'Körfez', 41),
(553, 'Derince', 41),
(554, 'Başiskele', 41),
(555, 'Çayırova', 41),
(556, 'Darıca', 41),
(557, 'Dilovası', 41),
(558, 'İzmit', 41),
(559, 'Kartepe', 41),
(560, 'Akşehir', 42),
(561, 'Beyşehir', 42),
(562, 'Bozkır', 42),
(563, 'Cihanbeyli', 42),
(564, 'Çumra', 42),
(565, 'Doğanhisar', 42),
(566, 'Ereğli / Konya', 42),
(567, 'Hadim', 42),
(568, 'Ilgın', 42),
(569, 'Kadınhanı', 42),
(570, 'Karapınar', 42),
(571, 'Kulu', 42),
(572, 'Sarayönü', 42),
(573, 'Seydişehir', 42),
(574, 'Yunak', 42),
(575, 'Akören', 42),
(576, 'Altınekin', 42),
(577, 'Derebucak', 42),
(578, 'Hüyük', 42),
(579, 'Karatay', 42),
(580, 'Meram', 42),
(581, 'Selçuklu', 42),
(582, 'Taşkent', 42),
(583, 'Ahırlı', 42),
(584, 'Çeltik', 42),
(585, 'Derbent', 42),
(586, 'Emirgazi', 42),
(587, 'Güneysınır', 42),
(588, 'Halkapınar', 42),
(589, 'Tuzlukçu', 42),
(590, 'Yalıhüyük', 42),
(591, 'Altıntaş', 43),
(592, 'Domaniç', 43),
(593, 'Emet', 43),
(594, 'Gediz', 43),
(595, 'Kütahya Merkez', 43),
(596, 'Simav', 43),
(597, 'Tavşanlı', 43),
(598, 'Aslanapa', 43),
(599, 'Dumlupınar', 43),
(600, 'Hisarcık', 43),
(601, 'Şaphane', 43),
(602, 'Çavdarhisar', 43),
(603, 'Pazarlar', 43),
(604, 'Akçadağ', 44),
(605, 'Arapgir', 44),
(606, 'Arguvan', 44),
(607, 'Darende', 44),
(608, 'Doğanşehir', 44),
(609, 'Hekimhan', 44),
(610, 'Pütürge', 44),
(611, 'Yeşilyurt / Malatya', 44),
(612, 'Battalgazi', 44),
(613, 'Doğanyol', 44),
(614, 'Kale / Malatya', 44),
(615, 'Kuluncak', 44),
(616, 'Yazıhan', 44),
(617, 'Akhisar', 45),
(618, 'Alaşehir', 45),
(619, 'Demirci', 45),
(620, 'Gördes', 45),
(621, 'Kırkağaç', 45),
(622, 'Kula', 45),
(623, 'Salihli', 45),
(624, 'Sarıgöl', 45),
(625, 'Saruhanlı', 45),
(626, 'Selendi', 45),
(627, 'Soma', 45),
(628, 'Turgutlu', 45),
(629, 'Ahmetli', 45),
(630, 'Gölmarmara', 45),
(631, 'Köprübaşı / Manisa', 45),
(632, 'Şehzadeler', 45),
(633, 'Yunusemre', 45),
(634, 'Afşin', 46),
(635, 'Andırın', 46),
(636, 'Elbistan', 46),
(637, 'Göksun', 46),
(638, 'Pazarcık', 46),
(639, 'Türkoğlu', 46),
(640, 'Çağlayancerit', 46),
(641, 'Ekinözü', 46),
(642, 'Nurhak', 46),
(643, 'Dulkadiroğlu', 46),
(644, 'Onikişubat', 46),
(645, 'Derik', 47),
(646, 'Kızıltepe', 47),
(647, 'Mazıdağı', 47),
(648, 'Midyat', 47),
(649, 'Nusaybin', 47),
(650, 'Ömerli', 47),
(651, 'Savur', 47),
(652, 'Dargeçit', 47),
(653, 'Yeşilli', 47),
(654, 'Artuklu', 47),
(655, 'Bodrum', 48),
(656, 'Datça', 48),
(657, 'Fethiye', 48),
(658, 'Köyceğiz', 48),
(659, 'Marmaris', 48),
(660, 'Milas', 48),
(661, 'Ula', 48),
(662, 'Yatağan', 48),
(663, 'Dalaman', 48),
(664, 'Ortaca', 48),
(665, 'Kavaklıdere', 48),
(666, 'Menteşe', 48),
(667, 'Seydikemer', 48),
(668, 'Bulanık', 49),
(669, 'Malazgirt', 49),
(670, 'Muş Merkez', 49),
(671, 'Varto', 49),
(672, 'Hasköy', 49),
(673, 'Korkut', 49),
(674, 'Avanos', 50),
(675, 'Derinkuyu', 50),
(676, 'Gülşehir', 50),
(677, 'Hacıbektaş', 50),
(678, 'Kozaklı', 50),
(679, 'Nevşehir Merkez', 50),
(680, 'Ürgüp', 50),
(681, 'Acıgöl', 50),
(682, 'Bor', 51),
(683, 'Çamardı', 51),
(684, 'Niğde Merkez', 51),
(685, 'Ulukışla', 51),
(686, 'Altunhisar', 51),
(687, 'Çiftlik', 51),
(688, 'Akkuş', 52),
(689, 'Aybastı', 52),
(690, 'Fatsa', 52),
(691, 'Gölköy', 52),
(692, 'Korgan', 52),
(693, 'Kumru', 52),
(694, 'Mesudiye', 52),
(695, 'Perşembe', 52),
(696, 'Ulubey / Ordu', 52),
(697, 'Ünye', 52),
(698, 'Gülyalı', 52),
(699, 'Gürgentepe', 52),
(700, 'Çamaş', 52),
(701, 'Çatalpınar', 52),
(702, 'Çaybaşı', 52),
(703, 'İkizce', 52),
(704, 'Kabadüz', 52),
(705, 'Kabataş', 52),
(706, 'Altınordu', 52),
(707, 'Ardeşen', 53),
(708, 'Çamlıhemşin', 53),
(709, 'Çayeli', 53),
(710, 'Fındıklı', 53),
(711, 'İkizdere', 53),
(712, 'Kalkandere', 53),
(713, 'Pazar / Rize', 53),
(714, 'Rize Merkez', 53),
(715, 'Güneysu', 53),
(716, 'Derepazarı', 53),
(717, 'Hemşin', 53),
(718, 'İyidere', 53),
(719, 'Akyazı', 54),
(720, 'Geyve', 54),
(721, 'Hendek', 54),
(722, 'Karasu', 54),
(723, 'Kaynarca', 54),
(724, 'Sapanca', 54),
(725, 'Kocaali', 54),
(726, 'Pamukova', 54),
(727, 'Taraklı', 54),
(728, 'Ferizli', 54),
(729, 'Karapürçek', 54),
(730, 'Söğütlü', 54),
(731, 'Adapazarı', 54),
(732, 'Arifiye', 54),
(733, 'Erenler', 54),
(734, 'Serdivan', 54),
(735, 'Alaçam', 55),
(736, 'Bafra', 55),
(737, 'Çarşamba', 55),
(738, 'Havza', 55),
(739, 'Kavak', 55),
(740, 'Ladik', 55),
(741, 'Terme', 55),
(742, 'Vezirköprü', 55),
(743, 'Asarcık', 55),
(744, '19 Mayıs', 55),
(745, 'Salıpazarı', 55),
(746, 'Tekkeköy', 55),
(747, 'Ayvacık / Samsun', 55),
(748, 'Yakakent', 55),
(749, 'Atakum', 55),
(750, 'Canik', 55),
(751, 'İlkadım', 55),
(752, 'Baykan', 56),
(753, 'Eruh', 56),
(754, 'Kurtalan', 56),
(755, 'Pervari', 56),
(756, 'Siirt Merkez', 56),
(757, 'Şirvan', 56),
(758, 'Tillo', 56),
(759, 'Ayancık', 57),
(760, 'Boyabat', 57),
(761, 'Durağan', 57),
(762, 'Erfelek', 57),
(763, 'Gerze', 57),
(764, 'Sinop Merkez', 57),
(765, 'Türkeli', 57),
(766, 'Dikmen', 57),
(767, 'Saraydüzü', 57),
(768, 'Divriği', 58),
(769, 'Gemerek', 58),
(770, 'Gürün', 58),
(771, 'Hafik', 58),
(772, 'İmranlı', 58),
(773, 'Kangal', 58),
(774, 'Koyulhisar', 58),
(775, 'Sivas Merkez', 58),
(776, 'Suşehri', 58),
(777, 'Şarkışla', 58),
(778, 'Yıldızeli', 58),
(779, 'Zara', 58),
(780, 'Akıncılar', 58),
(781, 'Altınyayla / Sivas', 58),
(782, 'Doğanşar', 58),
(783, 'Gölova', 58),
(784, 'Ulaş', 58),
(785, 'Çerkezköy', 59),
(786, 'Çorlu', 59),
(787, 'Hayrabolu', 59),
(788, 'Malkara', 59),
(789, 'Muratlı', 59),
(790, 'Saray / Tekirdağ', 59),
(791, 'Şarköy', 59),
(792, 'Marmaraereğlisi', 59),
(793, 'Ergene', 59),
(794, 'Kapaklı', 59),
(795, 'Süleymanpaşa', 59),
(796, 'Almus', 60),
(797, 'Artova', 60),
(798, 'Erbaa', 60),
(799, 'Niksar', 60),
(800, 'Reşadiye', 60),
(801, 'Tokat Merkez', 60),
(802, 'Turhal', 60),
(803, 'Zile', 60),
(804, 'Pazar / Tokat', 60),
(805, 'Yeşilyurt / Tokat', 60),
(806, 'Başçiftlik', 60),
(807, 'Sulusaray', 60),
(808, 'Akçaabat', 61),
(809, 'Araklı', 61),
(810, 'Arsin', 61),
(811, 'Çaykara', 61),
(812, 'Maçka', 61),
(813, 'Of', 61),
(814, 'Sürmene', 61),
(815, 'Tonya', 61),
(816, 'Vakfıkebir', 61),
(817, 'Yomra', 61),
(818, 'Beşikdüzü', 61),
(819, 'Şalpazarı', 61),
(820, 'Çarşıbaşı', 61),
(821, 'Dernekpazarı', 61),
(822, 'Düzköy', 61),
(823, 'Hayrat', 61),
(824, 'Köprübaşı / Trabzon', 61),
(825, 'Ortahisar', 61),
(826, 'Çemişgezek', 62),
(827, 'Hozat', 62),
(828, 'Mazgirt', 62),
(829, 'Nazımiye', 62),
(830, 'Ovacık / Tunceli', 62),
(831, 'Pertek', 62),
(832, 'Pülümür', 62),
(833, 'Tunceli Merkez', 62),
(834, 'Akçakale', 63),
(835, 'Birecik', 63),
(836, 'Bozova', 63),
(837, 'Ceylanpınar', 63),
(838, 'Halfeti', 63),
(839, 'Hilvan', 63),
(840, 'Siverek', 63),
(841, 'Suruç', 63),
(842, 'Viranşehir', 63),
(843, 'Harran', 63),
(844, 'Eyyübiye', 63),
(845, 'Haliliye', 63),
(846, 'Karaköprü', 63),
(847, 'Banaz', 64),
(848, 'Eşme', 64),
(849, 'Karahallı', 64),
(850, 'Sivaslı', 64),
(851, 'Ulubey / Uşak', 64),
(852, 'Uşak Merkez', 64),
(853, 'Başkale', 65),
(854, 'Çatak', 65),
(855, 'Erciş', 65),
(856, 'Gevaş', 65),
(857, 'Gürpınar', 65),
(858, 'Muradiye', 65),
(859, 'Özalp', 65),
(860, 'Bahçesaray', 65),
(861, 'Çaldıran', 65),
(862, 'Edremit / Van', 65),
(863, 'Saray / Van', 65),
(864, 'İpekyolu', 65),
(865, 'Tuşba', 65),
(866, 'Akdağmadeni', 66),
(867, 'Boğazlıyan', 66),
(868, 'Çayıralan', 66),
(869, 'Çekerek', 66),
(870, 'Sarıkaya', 66),
(871, 'Sorgun', 66),
(872, 'Şefaatli', 66),
(873, 'Yerköy', 66),
(874, 'Yozgat Merkez', 66),
(875, 'Aydıncık / Yozgat', 66),
(876, 'Çandır', 66),
(877, 'Kadışehri', 66),
(878, 'Saraykent', 66),
(879, 'Yenifakılı', 66),
(880, 'Çaycuma', 67),
(881, 'Devrek', 67),
(882, 'Ereğli / Zonguldak', 67),
(883, 'Zonguldak Merkez', 67),
(884, 'Alaplı', 67),
(885, 'Gökçebey', 67),
(886, 'Kilimli', 67),
(887, 'Kozlu', 67),
(888, 'Aksaray Merkez', 68),
(889, 'Ortaköy / Aksaray', 68),
(890, 'Ağaçören', 68),
(891, 'Güzelyurt', 68),
(892, 'Sarıyahşi', 68),
(893, 'Eskil', 68),
(894, 'Gülağaç', 68),
(895, 'Bayburt Merkez', 69),
(896, 'Aydıntepe', 69),
(897, 'Demirözü', 69),
(898, 'Ermenek', 70),
(899, 'Karaman Merkez', 70),
(900, 'Ayrancı', 70),
(901, 'Kazımkarabekir', 70),
(902, 'Başyayla', 70),
(903, 'Sarıveliler', 70),
(904, 'Delice', 71),
(905, 'Keskin', 71),
(906, 'Kırıkkale Merkez', 71),
(907, 'Sulakyurt', 71),
(908, 'Bahşili', 71),
(909, 'Balışeyh', 71),
(910, 'Çelebi', 71),
(911, 'Karakeçili', 71),
(912, 'Yahşihan', 71),
(913, 'Batman Merkez', 72),
(914, 'Beşiri', 72),
(915, 'Gercüş', 72),
(916, 'Kozluk', 72),
(917, 'Sason', 72),
(918, 'Hasankeyf', 72),
(919, 'Beytüşşebap', 73),
(920, 'Cizre', 73),
(921, 'İdil', 73),
(922, 'Silopi', 73),
(923, 'Şırnak Merkez', 73),
(924, 'Uludere', 73),
(925, 'Güçlükonak', 73),
(926, 'Bartın Merkez', 74),
(927, 'Kurucaşile', 74),
(928, 'Ulus', 74),
(929, 'Amasra', 74),
(930, 'Ardahan Merkez', 75),
(931, 'Çıldır', 75),
(932, 'Göle', 75),
(933, 'Hanak', 75),
(934, 'Posof', 75),
(935, 'Damal', 75),
(936, 'Aralık', 76),
(937, 'Iğdır Merkez', 76),
(938, 'Tuzluca', 76),
(939, 'Karakoyunlu', 76),
(940, 'Yalova Merkez', 77),
(941, 'Altınova', 77),
(942, 'Armutlu', 77),
(943, 'Çınarcık', 77),
(944, 'Çiftlikköy', 77),
(945, 'Termal', 77),
(946, 'Eflani', 78),
(947, 'Eskipazar', 78),
(948, 'Karabük Merkez', 78),
(949, 'Ovacık / Karabük', 78),
(950, 'Safranbolu', 78),
(951, 'Yenice / Karabük', 78),
(952, 'Kilis Merkez', 79),
(953, 'Elbeyli', 79),
(954, 'Musabeyli', 79),
(955, 'Polateli', 79),
(956, 'Bahçe', 80),
(957, 'Kadirli', 80),
(958, 'Osmaniye Merkez', 80),
(959, 'Düziçi', 80),
(960, 'Hasanbeyli', 80),
(961, 'Sumbas', 80),
(962, 'Toprakkale', 80),
(963, 'Akçakoca', 81),
(964, 'Düzce Merkez', 81),
(965, 'Yığılca', 81),
(966, 'Cumayeri', 81),
(967, 'Gölyaka', 81),
(968, 'Çilimli', 81),
(969, 'Gümüşova', 81),
(970, 'Kaynaşlı', 81);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_sub_user`
--

CREATE TABLE `tb_sub_user` (
  `ID` int(10) UNSIGNED DEFAULT NULL,
  `SUB_USER_ID` int(10) UNSIGNED DEFAULT NULL,
  `CREATED_BY_USER_ID` int(10) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Tablo döküm verisi `tb_sub_user`
--

INSERT INTO `tb_sub_user` (`ID`, `SUB_USER_ID`, `CREATED_BY_USER_ID`) VALUES
(NULL, 7, 1);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_user`
--

CREATE TABLE `tb_user` (
  `ID` int(10) UNSIGNED NOT NULL,
  `FACEBOOK_ID` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `FIRSTNAME` varchar(100) CHARACTER SET utf8 NOT NULL,
  `LASTNAME` varchar(100) CHARACTER SET utf8 NOT NULL,
  `EMAIL` varchar(150) CHARACTER SET utf8 DEFAULT NULL,
  `GENDER` tinyint(4) DEFAULT NULL,
  `AGE` varchar(10) DEFAULT NULL,
  `CITY_ID` int(10) UNSIGNED DEFAULT NULL,
  `STATE_ID` int(10) UNSIGNED DEFAULT NULL,
  `PASSWORD_HASH` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `VERIFIED` tinyint(1) DEFAULT 0,
  `VERIFY_CODE` char(8) DEFAULT NULL,
  `REGISTER_IP` varchar(15) CHARACTER SET utf8 DEFAULT NULL,
  `CREATED_DATE` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Tablo döküm verisi `tb_user`
--
-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_user_list_share`
--

CREATE TABLE `tb_user_list_share` (
  `ID` int(10) UNSIGNED NOT NULL,
  `SHARE_CODE` char(8) CHARACTER SET utf8 DEFAULT NULL,
  `USER_ID` int(10) UNSIGNED DEFAULT NULL,
  `LIST_ID` int(10) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Tablo döküm verisi `tb_user_list_share`
--

INSERT INTO `tb_user_list_share` (`ID`, `SHARE_CODE`, `USER_ID`, `LIST_ID`) VALUES
(1, '13389001', 1, 1),
(2, '63973594', 7, 1),
(3, '35862078', 1, 6),
(4, '08568001', 3, 7);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_user_password_reset`
--

CREATE TABLE `tb_user_password_reset` (
  `ID` int(10) UNSIGNED NOT NULL,
  `USER_ID` int(10) UNSIGNED DEFAULT NULL,
  `RESET_CODE` varchar(6) CHARACTER SET utf8 DEFAULT NULL,
  `REQUEST_IP` varchar(15) CHARACTER SET utf8 NOT NULL,
  `REQUEST_DATE` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_user_variable`
--

CREATE TABLE `tb_user_variable` (
  `ID` int(10) UNSIGNED NOT NULL,
  `USER_ID` int(10) UNSIGNED DEFAULT NULL,
  `VARIABLE_ID` int(10) UNSIGNED DEFAULT NULL,
  `VARIABLE_VALUE_START` varchar(100) DEFAULT NULL,
  `VARIABLE_VALUE_END` varchar(100) DEFAULT NULL,
  `LAST_UPDATED` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Tablo döküm verisi `tb_user_variable`
--

INSERT INTO `tb_user_variable` (`ID`, `USER_ID`, `VARIABLE_ID`, `VARIABLE_VALUE_START`, `VARIABLE_VALUE_END`, `LAST_UPDATED`) VALUES
(1, 1, 1, '25', NULL, '2022-06-10'),
(2, 1, 2, '56', NULL, '2022-06-10'),
(3, 1, 3, '36', NULL, '2022-06-10'),
(4, 1, 4, '177', NULL, '2022-06-10'),
(5, 1, 5, '1', NULL, '2022-06-10'),
(6, 1, 6, '1', NULL, '2022-06-10'),
(7, 1, 7, '1', NULL, '2022-06-10'),
(8, 1, 8, '1', NULL, '2022-06-10'),
(9, 1, 9, '1', NULL, '2022-06-10'),
(10, 1, 10, '5', NULL, '2022-06-10'),
(11, 1, 11, '8', NULL, '2022-06-10'),
(12, 1, 12, '98', NULL, '2022-06-10'),
(13, 1, 13, '33', NULL, '2022-06-10'),
(14, 1, 14, '6', NULL, '2022-06-10'),
(15, 1, 15, '3', NULL, '2022-06-10'),
(16, 1, 16, '9', NULL, '2022-06-10'),
(17, 1, 17, '6', NULL, '2022-06-10'),
(18, 1, 18, '9', NULL, '2022-06-10'),
(19, 1, 19, '8', NULL, '2022-06-10'),
(20, 1, 20, '5', NULL, '2022-06-10'),
(21, 1, 21, '6', NULL, '2022-06-10'),
(22, 1, 22, '933333', NULL, '2022-06-10'),
(23, 1, 23, '6', NULL, '2022-06-10'),
(47, 7, 1, '595', NULL, '2022-06-11'),
(48, 7, 2, '595', NULL, '2022-06-11'),
(49, 7, 3, '595', NULL, '2022-06-11'),
(50, 7, 4, '595', NULL, '2022-06-11'),
(51, 7, 5, '595', NULL, '2022-06-11'),
(52, 7, 6, '595', NULL, '2022-06-11'),
(53, 7, 7, '595', NULL, '2022-06-11'),
(54, 7, 8, '595', NULL, '2022-06-11'),
(55, 7, 9, '595', NULL, '2022-06-11'),
(56, 7, 10, '595', NULL, '2022-06-11'),
(57, 7, 11, '595', NULL, '2022-06-11'),
(58, 7, 12, '595', NULL, '2022-06-11'),
(59, 7, 13, '595', NULL, '2022-06-11'),
(60, 7, 14, '595', NULL, '2022-06-11'),
(61, 7, 15, '595', NULL, '2022-06-11'),
(62, 7, 16, '595', NULL, '2022-06-11'),
(63, 7, 17, '595', NULL, '2022-06-11'),
(64, 7, 18, '595', NULL, '2022-06-11'),
(65, 7, 19, '595', NULL, '2022-06-11'),
(66, 7, 20, '595', NULL, '2022-06-11'),
(67, 7, 21, '595', NULL, '2022-06-11'),
(68, 7, 22, '595', NULL, '2022-06-11'),
(69, 7, 23, '595', NULL, '2022-06-11'),
(93, 3, 1, '595', NULL, NULL),
(94, 3, 2, '595', NULL, NULL),
(95, 3, 3, '595', NULL, NULL),
(96, 3, 4, '595', NULL, NULL),
(97, 3, 5, '595', NULL, NULL),
(98, 3, 6, '595', NULL, NULL),
(99, 3, 7, '595', NULL, NULL),
(100, 3, 8, '595', NULL, NULL),
(101, 3, 9, '595', NULL, NULL),
(102, 3, 10, '595', NULL, NULL),
(103, 3, 11, '595', NULL, NULL),
(104, 3, 12, '595', NULL, NULL),
(105, 3, 13, '595', NULL, NULL),
(106, 3, 14, '595', NULL, NULL),
(107, 3, 15, '595', NULL, NULL),
(108, 3, 16, '595', NULL, NULL),
(109, 3, 17, '595', NULL, NULL),
(110, 3, 18, '595', NULL, NULL),
(111, 3, 19, '595', NULL, NULL),
(112, 3, 20, '595', NULL, NULL),
(113, 3, 21, '595', NULL, NULL),
(114, 3, 22, '595', NULL, NULL),
(115, 3, 23, '595', NULL, NULL);

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_variable`
--

CREATE TABLE `tb_variable` (
  `ID` int(10) UNSIGNED NOT NULL,
  `TITLE` varchar(50) CHARACTER SET utf8 DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Tablo döküm verisi `tb_variable`
--

INSERT INTO `tb_variable` (`ID`, `TITLE`) VALUES
(1, 'Kilo'),
(2, 'Boy'),
(3, 'Kafa'),
(4, 'Boyun'),
(5, 'Omuz Boy'),
(6, 'Üst Kısım'),
(7, 'Alt Kısım'),
(8, 'Omuz'),
(9, 'Sağ Kol Uzunluk'),
(10, 'Sağ Pazu'),
(11, 'Sağ Kol Ön Kas'),
(12, 'Sol Kol Uzunluk'),
(13, 'Sol Pazu'),
(14, 'Sol Kol Ön Kas'),
(15, 'Göğüs'),
(16, 'Göbek'),
(17, 'Bel'),
(18, 'Kalça'),
(19, 'Sağ Baldır'),
(20, 'Sağ Diz Altı Kas'),
(21, 'Sol Baldır'),
(22, 'Sol Diz Altı Kas'),
(23, 'Ayaklar');

--
-- Dökümü yapılmış tablolar için indeksler
--

--
-- Tablo için indeksler `tb_category`
--
ALTER TABLE `tb_category`
  ADD PRIMARY KEY (`ID`);

--
-- Tablo için indeksler `tb_city`
--
ALTER TABLE `tb_city`
  ADD PRIMARY KEY (`ID`);

--
-- Tablo için indeksler `tb_coach`
--
ALTER TABLE `tb_coach`
  ADD PRIMARY KEY (`ID`);

--
-- Tablo için indeksler `tb_coach_password_reset`
--
ALTER TABLE `tb_coach_password_reset`
  ADD PRIMARY KEY (`ID`);

--
-- Tablo için indeksler `tb_list`
--
ALTER TABLE `tb_list`
  ADD PRIMARY KEY (`ID`);

--
-- Tablo için indeksler `tb_list_used_by_user`
--
ALTER TABLE `tb_list_used_by_user`
  ADD PRIMARY KEY (`ID`);

--
-- Tablo için indeksler `tb_list_variable`
--
ALTER TABLE `tb_list_variable`
  ADD PRIMARY KEY (`ID`);

--
-- Tablo için indeksler `tb_state`
--
ALTER TABLE `tb_state`
  ADD PRIMARY KEY (`ID`);

--
-- Tablo için indeksler `tb_user`
--
ALTER TABLE `tb_user`
  ADD PRIMARY KEY (`ID`);

--
-- Tablo için indeksler `tb_user_list_share`
--
ALTER TABLE `tb_user_list_share`
  ADD PRIMARY KEY (`ID`);

--
-- Tablo için indeksler `tb_user_password_reset`
--
ALTER TABLE `tb_user_password_reset`
  ADD PRIMARY KEY (`ID`);

--
-- Tablo için indeksler `tb_user_variable`
--
ALTER TABLE `tb_user_variable`
  ADD PRIMARY KEY (`ID`);

--
-- Tablo için indeksler `tb_variable`
--
ALTER TABLE `tb_variable`
  ADD PRIMARY KEY (`ID`);

--
-- Dökümü yapılmış tablolar için AUTO_INCREMENT değeri
--

--
-- Tablo için AUTO_INCREMENT değeri `tb_category`
--
ALTER TABLE `tb_category`
  MODIFY `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- Tablo için AUTO_INCREMENT değeri `tb_city`
--
ALTER TABLE `tb_city`
  MODIFY `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=82;

--
-- Tablo için AUTO_INCREMENT değeri `tb_coach`
--
ALTER TABLE `tb_coach`
  MODIFY `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- Tablo için AUTO_INCREMENT değeri `tb_coach_password_reset`
--
ALTER TABLE `tb_coach_password_reset`
  MODIFY `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Tablo için AUTO_INCREMENT değeri `tb_list`
--
ALTER TABLE `tb_list`
  MODIFY `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- Tablo için AUTO_INCREMENT değeri `tb_list_used_by_user`
--
ALTER TABLE `tb_list_used_by_user`
  MODIFY `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- Tablo için AUTO_INCREMENT değeri `tb_list_variable`
--
ALTER TABLE `tb_list_variable`
  MODIFY `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- Tablo için AUTO_INCREMENT değeri `tb_state`
--
ALTER TABLE `tb_state`
  MODIFY `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=971;

--
-- Tablo için AUTO_INCREMENT değeri `tb_user`
--
ALTER TABLE `tb_user`
  MODIFY `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- Tablo için AUTO_INCREMENT değeri `tb_user_list_share`
--
ALTER TABLE `tb_user_list_share`
  MODIFY `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Tablo için AUTO_INCREMENT değeri `tb_user_password_reset`
--
ALTER TABLE `tb_user_password_reset`
  MODIFY `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Tablo için AUTO_INCREMENT değeri `tb_user_variable`
--
ALTER TABLE `tb_user_variable`
  MODIFY `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=116;

--
-- Tablo için AUTO_INCREMENT değeri `tb_variable`
--
ALTER TABLE `tb_variable`
  MODIFY `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
