-- MySQL dump 10.13  Distrib 5.5.31, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: procurement
-- ------------------------------------------------------
-- Server version	5.5.31-0ubuntu0.13.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `cpv_groups`
--

DROP TABLE IF EXISTS `cpv_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cpv_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `translation` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=71 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cpv_groups`
--

LOCK TABLES `cpv_groups` WRITE;
/*!40000 ALTER TABLE `cpv_groups` DISABLE KEYS */;
INSERT INTO `cpv_groups` VALUES (1,'2013-03-01 11:58:03','2013-03-01 11:58:03',2,'All Sectors',NULL,NULL),(2,'2013-03-01 11:58:03','2013-03-01 11:58:03',2,'Risky',NULL,NULL),(26,'2013-05-13 11:20:26','2013-05-13 11:20:26',3,'My cpv group',NULL,NULL),(42,'2013-05-30 13:49:49','2013-05-30 13:49:49',1,'music',NULL,NULL),(44,'2013-06-11 12:10:39','2013-06-21 07:02:49',2,'Construction',NULL,'მშენებლობა'),(46,'2013-06-11 12:13:01','2013-06-21 07:03:54',2,'Health',NULL,'ჯანმრთელობა'),(47,'2013-06-11 12:14:33','2013-06-21 07:38:54',2,'Social Programs',NULL,'სოციალური პროგრამები'),(48,'2013-06-11 12:15:30','2013-06-21 07:39:04',2,'Defence',NULL,'თავდაცვა'),(49,'2013-06-11 12:16:42','2013-06-21 07:39:22',2,'Oil and Gas',NULL,'გაზი და საწვავი'),(50,'2013-06-11 12:18:30','2013-06-21 07:39:34',2,'Telecommunications',NULL,'ტელეკომუნიკაციები'),(51,'2013-06-11 12:18:52','2013-06-21 07:40:24',2,'Utility Sectors',NULL,'კომუნალური სექტორი'),(52,'2013-06-11 12:19:44','2013-06-21 08:07:33',2,'Mining',NULL,'სამთო მრეწველობა'),(54,'2013-06-13 07:24:46','2013-06-21 07:42:30',2,'99999999 – Not Specified',NULL,'99999999- განუსაზღვრელი'),(56,'2013-06-13 08:44:57','2013-06-21 08:08:13',2,'Consulting',NULL,'საკონსულტაციო მომსახურება'),(58,'2013-06-14 07:06:26','2013-06-21 07:43:19',2,'Cars, vehicles, transportation',NULL,'მანქანები, სატრანსპორტო საშუალებები'),(59,'2013-06-14 07:07:22','2013-06-21 07:44:31',2,'IT, software',NULL,'კომპიუტერული ტექნოლოგიები და უზრუნველყოფა'),(60,'2013-06-14 12:14:16','2013-06-21 08:09:30',2,'Medical equipment, pharmaceuticals',NULL,'სამედიცინო  აღჭურვილობა და ფარმაცევტული პროდუქცია'),(61,'2013-06-14 12:14:43','2013-06-21 07:45:50',2,'Food, beverages',NULL,'საჭმელი და სასმელი'),(62,'2013-06-14 12:16:33','2013-06-21 07:46:26',2,'Financial services, insurance',NULL,'ფინანსური სერვისი და დაზღვევა'),(63,'2013-06-14 12:18:08','2013-06-21 07:48:07',2,'Agriculture: products, services, machinery',NULL,'სასოფლო-სამეურნეო პროდუქტი,სერვისი და მანქანები'),(64,'2013-06-15 10:59:02','2013-06-21 08:10:14',2,'Advertising',NULL,'სარეკლამო მომსახურება'),(65,'2013-06-16 17:59:38','2013-06-16 17:59:38',29,'',NULL,NULL),(66,'2013-06-17 14:15:12','2013-06-17 14:15:12',32,'კოალიცია და',NULL,NULL),(67,'2013-06-18 15:48:37','2013-06-18 15:48:37',20,'Radio, telecom related equipment',NULL,NULL),(68,'2013-06-19 06:13:57','2013-06-19 06:13:57',41,'surveillance equipment',NULL,NULL),(69,'2013-07-01 14:42:43','2013-07-01 14:42:43',53,'',NULL,NULL),(70,'2013-07-04 20:46:56','2013-07-04 20:46:56',59,'',NULL,NULL);
/*!40000 ALTER TABLE `cpv_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `procurer_watches`
--

DROP TABLE IF EXISTS `procurer_watches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `procurer_watches` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `procurer_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `diff_hash` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email_alert` tinyint(1) DEFAULT NULL,
  `has_updated` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `procurer_watches`
--

LOCK TABLES `procurer_watches` WRITE;
/*!40000 ALTER TABLE `procurer_watches` DISABLE KEYS */;
INSERT INTO `procurer_watches` VALUES (19,1,'372',NULL,NULL,0,'2013-06-06 11:44:45','2013-06-06 11:49:30'),(20,21,'81',NULL,NULL,NULL,'2013-06-13 13:24:05','2013-06-13 13:24:05'),(21,22,'1324',NULL,NULL,0,'2013-06-14 11:58:57','2013-06-14 12:34:29'),(22,37,'43',NULL,NULL,NULL,'2013-06-18 08:37:52','2013-06-18 08:37:52');
/*!40000 ALTER TABLE `procurer_watches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `searches`
--

DROP TABLE IF EXISTS `searches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `searches` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `search_string` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `searchtype` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `count` int(11) DEFAULT NULL,
  `email_alert` tinyint(1) DEFAULT NULL,
  `has_updated` tinyint(1) DEFAULT NULL,
  `last_viewed` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `searches`
--

LOCK TABLES `searches` WRITE;
/*!40000 ALTER TABLE `searches` DISABLE KEYS */;
INSERT INTO `searches` VALUES (21,3,'_#26#%%#%%#_#_#_#_#_#_#_#_#_#_#%%#%%#','2013-05-13 11:21:27','2013-05-13 11:21:58','my cpv group search','tender',4560,1,0,'2013-05-13 11:21:58'),(23,3,'_#_#_#','2013-05-13 11:22:27','2013-05-13 12:02:40','all procurers','procurer',NULL,NULL,0,'2013-05-13 12:02:40'),(25,3,'_#_#_#_#_#_#_#_#','2013-05-13 12:17:03','2013-05-13 12:17:07','all','supplier',7693,NULL,0,'2013-05-13 12:17:07'),(26,3,'შპს   GEO MASTER#_#_#_#_#_#_#_#','2013-05-13 12:17:19','2013-05-13 12:17:22','geo master','supplier',1,NULL,0,'2013-05-13 12:17:22'),(27,3,'_#_#50% მეტი სახ წილ საწარმო#','2013-05-13 12:17:35','2013-05-13 12:17:38','50 percent','procurer',245,NULL,0,'2013-05-13 12:17:38'),(38,1,'_#1#%%#ხელშეკრულება დადებულია#ელექტრონული ტენდერი #_#_#100000#_#_#_#_#_#_#%%#%%#_#','2013-06-06 12:16:28','2013-06-06 12:16:34','3620','tender',3620,NULL,0,'2013-06-06 12:16:34'),(39,1,'_#_#_#_#_#_#_#1#_#','2013-06-06 12:43:11','2013-06-13 20:19:40','foreign','supplier',63,NULL,0,'2013-06-13 20:19:40'),(42,21,'_#1#%%#%%#_#_#_#50000#_#_#_#_#_#_#%ქ. თბილისის მერია%#%%#_#','2013-06-13 13:25:33','2013-06-14 08:51:53','Big Tbilisi Tenders','tender',666,NULL,0,'2013-06-14 08:51:53'),(43,22,'_#1#%%#%%#_#_#_#_#_#_#_#_#_#_#%%#%შ.პ.ს. ალიანსი%#_#','2013-06-14 11:50:58','2013-06-14 11:50:58','დაგი','tender',0,NULL,NULL,'2013-06-14 11:50:58'),(44,36,'თელავის მუნიციპალიტეტი#231280093#ადგილობრივი თვითმართველობის ორგანო#','2013-06-18 07:16:41','2013-06-18 07:16:41','თელავის მუნიციპალიტეტი','procurer',2,NULL,NULL,'2013-06-18 07:16:41'),(46,36,'_#1#%%#%%#_#_#_#_#_#_#_#_#_#_#%თელავის მუნიციპალიტეტი%#%%#_#','2013-06-18 07:21:08','2013-06-18 07:21:08','თელავის მუნიციპალიტეტი','tender',NULL,NULL,NULL,'2013-06-18 07:21:08');
/*!40000 ALTER TABLE `searches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `supplier_watches`
--

DROP TABLE IF EXISTS `supplier_watches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `supplier_watches` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `supplier_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `diff_hash` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email_alert` tinyint(1) DEFAULT NULL,
  `has_updated` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=62 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `supplier_watches`
--

LOCK TABLES `supplier_watches` WRITE;
/*!40000 ALTER TABLE `supplier_watches` DISABLE KEYS */;
INSERT INTO `supplier_watches` VALUES (45,1,'1254',NULL,1,0,'2013-06-06 11:44:55','2013-06-11 06:36:33'),(58,21,'6575',NULL,NULL,NULL,'2013-06-13 13:23:31','2013-06-13 13:23:31'),(59,20,'877',NULL,NULL,0,'2013-06-15 12:15:15','2013-06-24 07:19:11'),(60,20,'3371',NULL,NULL,NULL,'2013-06-19 12:22:17','2013-06-19 12:22:17');
/*!40000 ALTER TABLE `supplier_watches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `encrypted_password` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `role` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `reset_password_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `reset_password_sent_at` datetime DEFAULT NULL,
  `remember_created_at` datetime DEFAULT NULL,
  `sign_in_count` int(11) DEFAULT '0',
  `current_sign_in_at` datetime DEFAULT NULL,
  `last_sign_in_at` datetime DEFAULT NULL,
  `current_sign_in_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_sign_in_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `confirmation_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `confirmed_at` datetime DEFAULT NULL,
  `confirmation_sent_at` datetime DEFAULT NULL,
  `unconfirmed_email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `authentication_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_email` (`email`),
  UNIQUE KEY `index_users_on_reset_password_token` (`reset_password_token`),
  UNIQUE KEY `index_users_on_confirmation_token` (`confirmation_token`),
  UNIQUE KEY `index_users_on_authentication_token` (`authentication_token`)
) ENGINE=InnoDB AUTO_INCREMENT=60 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'chris@transparency.ge','$2a$10$G5N/v83i5v84Ibr3Q5B4g.CCfW.4MhNtZjftFjWQFEsplJvU2vCi2','admin','7WcKzALDzzyTfzwkyxVF','2013-06-24 07:12:28',NULL,55,'2013-06-21 14:15:03','2013-06-21 11:30:46','85.117.42.89','85.117.42.89','2013-03-01 11:58:03','2013-06-24 07:12:28',NULL,'2013-06-12 07:20:22','2013-06-12 07:19:38',NULL,NULL),(2,'profile@transparency.ge','$2a$10$Wm3rpaZTBLSBPiy8v5Pfr.iZ/Fm7gc85YqPQcSFsXldLQgj8YHnqa','profile',NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,'2013-03-01 11:58:03','2013-03-01 11:58:03',NULL,NULL,NULL,NULL,NULL),(20,'mathias.huter@gmail.com','$2a$10$fBi3SvCkMCbz5x/efZbXI.5HHLdblqUDNCae/wE9VQ/U/5gkZvene','admin','JKitq81LhyzfZ7Gk8XPy','2013-06-13 06:22:05','2013-06-14 12:13:03',14,'2013-06-26 13:34:50','2013-06-24 06:50:06','85.117.42.89','85.117.42.89','2013-06-13 06:12:35','2013-06-26 13:34:50',NULL,'2013-06-13 06:13:09','2013-06-13 06:12:35',NULL,NULL),(21,'derek@transparency.ge','$2a$10$7JBO9qsVs/MroWZCojbedefBe2c4xTqXaOXnkXOIT21sD.t0T4SmC','user',NULL,NULL,NULL,3,'2013-06-14 08:50:24','2013-06-13 13:19:07','95.104.117.182','192.168.0.79','2013-06-13 11:38:29','2013-06-14 08:50:24',NULL,'2013-06-13 11:39:44','2013-06-13 11:38:29',NULL,NULL),(22,'turjumelashvili@spa.ge','$2a$10$0imcZWcO11ri5Rl5ap3mHesVVQZxS3Fqn.Li/IrndG14ZHqkum/La','user',NULL,NULL,'2013-07-03 16:47:41',5,'2013-07-03 16:47:41','2013-06-21 07:35:21','80.241.255.194','80.241.255.194','2013-06-14 11:48:59','2013-07-03 16:47:41',NULL,'2013-06-14 11:49:28','2013-06-14 11:48:59',NULL,NULL),(23,'frances@francesbelser.com','$2a$10$/90j1yckFH0xTMDu8DD8Meo0k3ie8c2hpUoYlNVhiNadZEfMsK1.C','user',NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,'2013-06-14 13:04:00','2013-06-14 13:04:00','QK7fjyeKLnfo5DNyMzX3',NULL,'2013-06-14 13:04:00',NULL,NULL),(24,'giorgi.vashakidze@gmail.com','$2a$10$4cUceD5g3EqqQKC.IHhUaOY/M5jkO41A0FustfWI7mN5sy/S7Cvva','user',NULL,NULL,NULL,1,'2013-06-14 13:30:13','2013-06-14 13:30:13','188.62.239.57','188.62.239.57','2013-06-14 13:27:38','2013-06-14 13:30:13',NULL,'2013-06-14 13:30:13','2013-06-14 13:27:38',NULL,NULL),(25,'vgagnidze@tpdc.ge','$2a$10$7Xu2i9fCoKiKYlipBL8wNee.zFNPngobAeBO1p1MkOZPiHiSUlCzS','user',NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,'2013-06-14 13:27:58','2013-06-14 13:27:58','ujD2vnu7TiYQHJDzxpWR',NULL,'2013-06-14 13:27:58',NULL,NULL),(26,'ekar@transparency.ge','$2a$10$y96Z50ManWomutqCkCkXXeo0WdZf0C2h224M0CHOI9akx2U0hq0jm','user',NULL,NULL,NULL,1,'2013-06-14 19:44:21','2013-06-14 19:44:21','31.146.130.58','31.146.130.58','2013-06-14 19:44:01','2013-06-14 19:44:21',NULL,'2013-06-14 19:44:21','2013-06-14 19:44:01',NULL,NULL),(27,'irmazoidze@gmail.com','$2a$10$pCURhYJbssOFj5g75qaojOTxdmvt7IU3prmRbanL5XEZ0hGw911Qa','user',NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,'2013-06-15 12:22:21','2013-06-15 12:22:21','aeHSUwrVhBeWyHxfZNmk',NULL,'2013-06-15 12:22:21',NULL,NULL),(28,'dimitri_papava@mail.ru','$2a$10$bQooUqhUdiwPr28L8CZKtOQHiNSYBjLxHWYIg98C5uoDmGEsqDCLa','user',NULL,NULL,NULL,1,'2013-06-16 07:07:10','2013-06-16 07:07:10','93.177.166.38','93.177.166.38','2013-06-15 18:40:49','2013-06-16 07:07:10',NULL,'2013-06-16 07:07:10','2013-06-15 18:40:49',NULL,NULL),(29,'sofokaldani@yahoo.com','$2a$10$MAQ8kQjY.OQM3tbPlI5uCuiY0CxyKZ9fYZv.skWBh6X9PiOucfSdW','user',NULL,NULL,NULL,1,'2013-06-16 17:56:16','2013-06-16 17:56:16','176.221.196.254','176.221.196.254','2013-06-16 17:55:12','2013-06-16 17:56:16',NULL,'2013-06-16 17:56:16','2013-06-16 17:55:12',NULL,NULL),(30,'gulokokhodze@gmail.com','$2a$10$L7.Nx6844JjAJrCrJ8AEMOMQDnmVnCH9JNjlPA1UPH5ejhU8fnG9a','user',NULL,NULL,NULL,1,'2013-06-18 07:15:17','2013-06-18 07:15:17','188.169.19.174','188.169.19.174','2013-06-17 12:22:13','2013-06-18 07:15:17',NULL,'2013-06-18 07:15:15','2013-06-17 12:22:13',NULL,NULL),(31,'ninoxeladze@yahoo.com','$2a$10$ABtym.yVuv/I95aA7Lm.r.viMinaClxzQUDScmQegQCCssD61jH.G','user',NULL,NULL,NULL,1,'2013-06-17 14:20:07','2013-06-17 14:20:07','109.238.236.218','109.238.236.218','2013-06-17 14:08:18','2013-06-17 14:20:07',NULL,'2013-06-17 14:20:07','2013-06-17 14:08:18',NULL,NULL),(32,'kobnadira@gmail.com','$2a$10$AmXxZ1OIp8Rge19APmJXOe5yU/NGOae7cFKI4CO.YjwH/D3xy.2Kq','user',NULL,NULL,NULL,2,'2013-06-17 16:46:21','2013-06-17 14:13:56','176.221.254.24','176.221.254.24','2013-06-17 14:12:30','2013-06-17 16:46:21',NULL,'2013-06-17 14:13:56','2013-06-17 14:12:30',NULL,NULL),(33,'adjareli@gmail.com','$2a$10$mWrWkuAuxWn8cERypTQKL.CuUgKtavWr5HnCmiIu.dPl1Dc2hzOve','user',NULL,NULL,NULL,1,'2013-06-17 14:21:46','2013-06-17 14:21:46','192.168.0.176','192.168.0.176','2013-06-17 14:20:52','2013-06-17 14:21:46',NULL,'2013-06-17 14:21:46','2013-06-17 14:20:52',NULL,NULL),(34,'makagonillc@gmail.com','$2a$10$MLWEMQJYqJj4xvmU7W1/T.DzbMvzPYS59KtBCBQZ9laJUvJ8kguUy','user',NULL,NULL,NULL,1,'2013-06-18 03:22:04','2013-06-18 03:22:04','92.54.219.183','92.54.219.183','2013-06-17 21:53:01','2013-06-18 03:22:04',NULL,'2013-06-18 03:22:04','2013-06-17 21:53:01',NULL,NULL),(35,'kirkita205@gmail.com','$2a$10$3O8O/Dn8m4cYRp1SKEN6K.mVAb6hnsAHYPkawoR25ZzpDi5rWXUqa','user',NULL,NULL,NULL,2,'2013-06-18 06:03:50','2013-06-18 06:03:30','219.140.160.210','219.140.160.210','2013-06-18 06:02:36','2013-06-18 06:03:50',NULL,'2013-06-18 06:03:30','2013-06-18 06:02:36',NULL,NULL),(36,'lbasilauri@yahoo.com','$2a$10$kAWXr8rYgpUm1FdrTnZZjeJgihf4T3wHtBr/1NgDW/10HlfrQv6Vi','user',NULL,NULL,NULL,3,'2013-06-18 11:24:08','2013-06-18 11:22:03','146.255.228.218','146.255.228.218','2013-06-18 07:12:12','2013-06-18 11:24:08',NULL,'2013-06-18 07:14:55','2013-06-18 07:12:12',NULL,NULL),(37,'l.xalishvili@gmail.com','$2a$10$IQxFyTgYR0Gl4CR6LfFanOvkfEf7vfWXRcAKI.ixGxaamEalOJ9x2','user',NULL,NULL,NULL,1,'2013-06-18 08:34:00','2013-06-18 08:34:00','31.146.184.10','31.146.184.10','2013-06-18 08:32:42','2013-06-18 08:34:00',NULL,'2013-06-18 08:33:59','2013-06-18 08:32:42',NULL,NULL),(38,'chrisbellboy@hotmail.com','$2a$10$.K3qnV3cvLs/Ysp4kBUwQ.9KvCzIhFumwNEMVzpQNTFJr5oZH/0pO','user',NULL,NULL,NULL,1,'2013-06-18 12:52:34','2013-06-18 12:52:34','92.241.84.186','92.241.84.186','2013-06-18 12:50:53','2013-06-18 12:52:34',NULL,'2013-06-18 12:52:34','2013-06-18 12:50:53',NULL,NULL),(39,'tamaziii@mail.ru','$2a$10$ZCJBTkTB8PxzhSJhZOtBguCSln.8bhTkk0sukP3lo1MaAvmISS4Zq','user',NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,'2013-06-18 15:05:59','2013-06-18 15:05:59','iyyz4vFsm1843fKSbRj1',NULL,'2013-06-18 15:05:59',NULL,NULL),(40,'nukri.khintibidze@gmail.com','$2a$10$QZAE0oySP2fByGD.PKvy1.k8x.0bwuKyUYDjpZ88BshNXGTyp2scS','user',NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,'2013-06-19 04:32:23','2013-06-19 04:32:23','E8FFepqGNpGNbT6FzYpz',NULL,'2013-06-19 04:32:22',NULL,NULL),(41,'jodymcp@yahoo.com','$2a$10$w3MKfICwcPgsgwiNap/M3eEgryW6kZIhyLkfnB6RRhMQUGzzS7.2K','user',NULL,NULL,NULL,1,'2013-06-19 06:11:10','2013-06-19 06:11:10','94.100.237.12','94.100.237.12','2013-06-19 06:10:20','2013-06-19 06:11:10',NULL,'2013-06-19 06:11:10','2013-06-19 06:10:20',NULL,NULL),(42,'i.zaridze@yahoo.com','$2a$10$Ddq/Lx.Nnbs3GE71EZT43uT/fIxDp1KwUb7t6APMRayz6vHVpHRXK','user',NULL,NULL,NULL,1,'2013-06-20 08:35:19','2013-06-20 08:35:19','37.232.111.115','37.232.111.115','2013-06-20 08:34:35','2013-06-20 08:35:19',NULL,'2013-06-20 08:35:19','2013-06-20 08:34:35',NULL,NULL),(43,'zukvara@mail.ru','$2a$10$4BYIAK2NA0imY/MytdI0keFd61NZvhgg8OY2H0dnucnlcnPJ1bMjG','user',NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,'2013-06-20 16:04:57','2013-06-20 16:04:57','wyBSb6y4GFxFFnvUArie',NULL,'2013-06-20 16:04:57',NULL,NULL),(44,'saba.hridc@yahoo.com','$2a$10$pEz155IMzDKAqWMeP1kCY.iaXap2xq3YHKoEAf21IET5W6FWGfLje','user',NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,'2013-06-22 11:23:06','2013-06-22 11:23:06','uWzzyjhj1RnvHpY4vUrj',NULL,'2013-06-22 11:23:06',NULL,NULL),(45,'okujavanona@yaooh.com','$2a$10$a6Z7haU6n7huA/bjK9ZnQOg29YTCAoKe2beWODX6CaNtq7UUiGC1q','user',NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,'2013-06-22 12:46:38','2013-06-22 12:46:38','sH5uPbm21S6pcXGejTuq',NULL,'2013-06-22 12:46:38',NULL,NULL),(46,'tagizi@email.ge','$2a$10$olHx5LFG62/Yh6DMCwW9F.FWlSmv3.LOmyVjLovZ4GR8Hyet/aRT2','user',NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,'2013-06-22 22:33:28','2013-06-22 22:33:28','wAPmmrK3XqnoafUvutvi',NULL,'2013-06-22 22:33:28',NULL,NULL),(47,'gioqveladze@yahoo.com','$2a$10$XUtF30Cnfi2vFaeQ6xd/Yueq7I/FVWQfMEhMflGXloczfcZP1t3va','user',NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,'2013-06-24 07:25:03','2013-06-24 07:25:03','qiixPjnotC8SV3odSkot',NULL,'2013-06-24 07:25:03',NULL,NULL),(48,'besikiivanashvili@mail.ru','$2a$10$ffzrIVOv5pNXSpIwUXzH5eedo5BpQHQOt8BcRBajw9tekfiJgehei','user',NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,'2013-06-24 14:07:14','2013-06-24 14:07:14','4yPpGQ8ZApfXbZyF3pdM',NULL,'2013-06-24 14:07:14',NULL,NULL),(49,'manyoreta@hotmail.com','$2a$10$PdgW36SaxxlPzYIjIglEMOJyOYTjzdundBT5lSrQCVx26PYsPu6AS','user',NULL,NULL,NULL,1,'2013-06-27 16:27:47','2013-06-27 16:27:47','200.34.175.252','200.34.175.252','2013-06-26 15:38:08','2013-06-27 16:27:47',NULL,'2013-06-27 16:27:47','2013-06-26 15:38:08',NULL,NULL),(50,'akukhaleishvili@mail.ru','$2a$10$gY8BWBztR8nwhhU1RTzGg.Bo93xyoE46IGDvch3WIapLmXkBmEJN6','user',NULL,NULL,NULL,1,'2013-06-28 06:29:09','2013-06-28 06:29:09','213.131.58.250','213.131.58.250','2013-06-28 06:25:16','2013-06-28 06:29:09',NULL,'2013-06-28 06:29:09','2013-06-28 06:25:16',NULL,NULL),(51,'eka.gordadze@galaxy.com.ge','$2a$10$RbH.nEZDsdi6HzuZ1MI4beUyBprdD5vAPOkTr4NYKQmEffqhoQxVa','user',NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,'2013-06-28 13:46:36','2013-06-28 13:46:36','8pNY9hoYDFzhj2F1goD4',NULL,'2013-06-28 13:46:36',NULL,NULL),(52,'alexander.rukhaia@gmail.com','$2a$10$ZSjyJ5Bv3HXqjYzwEUroyu71GWA6dlnOLupX3Rq2rcVQgFQoQ/C6.','user',NULL,NULL,NULL,1,'2013-07-01 10:37:21','2013-07-01 10:37:21','188.169.75.102','188.169.75.102','2013-07-01 10:36:37','2013-07-01 10:37:21',NULL,'2013-07-01 10:37:21','2013-07-01 10:36:37',NULL,NULL),(53,'mpachulia@gorbi.com','$2a$10$M//wPNE1y1mpBTtAdNp8fejVGyKbkEC4R0CVy2VNRrn5n4.9B7M8i','user',NULL,NULL,NULL,1,'2013-07-01 14:40:18','2013-07-01 14:40:18','95.104.116.171','95.104.116.171','2013-07-01 14:33:06','2013-07-01 14:40:18',NULL,'2013-07-01 14:40:18','2013-07-01 14:33:06',NULL,NULL),(54,'gelakochalidze@gmail.com','$2a$10$GqoDrbKE5y8LDG82V6L5vueL/45se7adygZ8owjs/NRcNQ0xdFwGi','user',NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,'2013-07-02 20:31:57','2013-07-02 20:31:57','qUSacSosJKvC2XhmzVg6',NULL,'2013-07-02 20:31:57',NULL,NULL),(55,'gigasutidze@gmail.com','$2a$10$74irGJBLdXCBOy4OVGi2v.EeZWg4Zmge9zBzxyEsON.YbqhIntyKK','user',NULL,NULL,NULL,1,'2013-07-03 04:57:50','2013-07-03 04:57:50','31.192.48.118','31.192.48.118','2013-07-03 04:55:37','2013-07-03 04:57:50',NULL,'2013-07-03 04:57:50','2013-07-03 04:55:37',NULL,NULL),(56,'maknugo8@mail.ru','$2a$10$tqFr05h0TelPwPJHChf6o.bzssnAIniMENRFD8m.PscFtI9/.tshW','user',NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,'2013-07-03 08:43:18','2013-07-03 08:43:18','Ww9REhCEFuMxsWedEgbD',NULL,'2013-07-03 08:43:18',NULL,NULL),(57,'kazmira2011@gmail.com','$2a$10$O3Py1nAxv3Xa6KcJf1SEq.Smhe4K47WDU9Qx1uCS5Vsq0Ib/HdcZO','user',NULL,NULL,NULL,1,'2013-07-04 09:27:56','2013-07-04 09:27:56','176.73.170.151','176.73.170.151','2013-07-04 09:27:00','2013-07-04 09:27:56',NULL,'2013-07-04 09:27:56','2013-07-04 09:27:00',NULL,NULL),(58,'m.beriashvili@court.ge','$2a$10$OIc9HvId3owF9FxO/57vf.xmNthnTJoQManLc837IWBLRERfVrB/m','user',NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,'2013-07-04 20:18:43','2013-07-04 20:18:43','YSyG2w67MSsUa2uqUSSq',NULL,'2013-07-04 20:18:43',NULL,NULL),(59,'beriashvili1177@gmail.com','$2a$10$2fZl.qKsO/RJgO0PZ8OTa.cfMOKOFia3k4U4gcrmHRvDA6QkyagBa','user',NULL,NULL,'2013-07-04 20:22:35',2,'2013-07-04 20:22:35','2013-07-04 20:22:10','149.3.111.249','149.3.111.249','2013-07-04 20:21:52','2013-07-04 20:22:35',NULL,'2013-07-04 20:22:10','2013-07-04 20:21:52',NULL,NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `watch_tenders`
--

DROP TABLE IF EXISTS `watch_tenders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `watch_tenders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `tender_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `diff_hash` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email_alert` tinyint(1) DEFAULT NULL,
  `has_updated` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `watch_tenders`
--

LOCK TABLES `watch_tenders` WRITE;
/*!40000 ALTER TABLE `watch_tenders` DISABLE KEYS */;
INSERT INTO `watch_tenders` VALUES (19,1,'5835','2013-06-06 12:19:13','2013-06-11 06:36:26',NULL,1,0),(22,21,'9095','2013-06-13 13:22:14','2013-06-13 13:22:15',NULL,1,NULL);
/*!40000 ALTER TABLE `watch_tenders` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2013-07-05 11:42:46
