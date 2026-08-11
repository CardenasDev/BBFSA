-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: bbf_administrativo
-- ------------------------------------------------------
-- Server version	5.5.5-10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `bbf_areas`
--

DROP TABLE IF EXISTS `bbf_areas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_areas` (
  `ID_AREA` int(11) NOT NULL AUTO_INCREMENT,
  `NOMBRE` varchar(150) NOT NULL,
  `DESCRIPCION` text DEFAULT NULL,
  `ACTIVO` tinyint(1) NOT NULL DEFAULT 1,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_AREA`),
  UNIQUE KEY `UQ_BBF_AREAS_NOMBRE` (`NOMBRE`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_areas`
--

LOCK TABLES `bbf_areas` WRITE;
/*!40000 ALTER TABLE `bbf_areas` DISABLE KEYS */;
INSERT INTO `bbf_areas` VALUES (2,'Administración','Área administrativa general',1,'2026-06-23 10:00:15',NULL),(3,'Recursos Humanos','Gestión administrativa y laboral del personal',1,'2026-06-23 10:00:15',NULL),(4,'Producción','Área operativa de cultivo y producción',1,'2026-06-23 10:00:15',NULL),(5,'Cultivo','Labores de cultivo, siembra, corte y mantenimiento',1,'2026-06-23 10:00:15',NULL),(6,'Poscosecha','Clasificación, empaque y manejo posterior al corte',1,'2026-06-23 10:00:15',NULL),(7,'Ventas','Gestión comercial y atención de clientes',1,'2026-06-23 10:00:15',NULL),(8,'Calidad','Control de calidad del producto y procesos',1,'2026-06-23 10:00:15',NULL),(9,'Logística','Despachos, transporte y coordinación operativa',1,'2026-06-23 10:00:15',NULL),(10,'Mantenimiento','Mantenimiento de infraestructura, equipos y herramientas',1,'2026-06-23 10:00:15',NULL),(11,'Sistemas','Soporte tecnológico y administración de sistemas',1,'2026-06-23 10:00:15',NULL);
/*!40000 ALTER TABLE `bbf_areas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_aspirante_documentos`
--

DROP TABLE IF EXISTS `bbf_aspirante_documentos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_aspirante_documentos` (
  `ID_ASPIRANTE_DOCUMENTO` int(11) NOT NULL AUTO_INCREMENT,
  `ID_ASPIRANTE` int(11) NOT NULL,
  `ID_TIPO_DOCUMENTO_LABORAL` int(11) NOT NULL,
  `NOMBRE_ARCHIVO` varchar(255) NOT NULL,
  `NOMBRE_ORIGINAL` varchar(255) DEFAULT NULL,
  `ARCHIVO_URL` varchar(500) DEFAULT NULL,
  `ARCHIVO_RUTA` varchar(500) DEFAULT NULL,
  `MIME_TYPE` varchar(100) DEFAULT NULL,
  `PESO_BYTES` bigint(20) DEFAULT NULL,
  `ESTADO_DOCUMENTO` enum('PENDIENTE','CARGADO','VALIDADO','RECHAZADO','VENCIDO') NOT NULL DEFAULT 'CARGADO',
  `OBSERVACIONES` text DEFAULT NULL,
  `ID_CARGADO_POR` int(11) DEFAULT NULL,
  `ELIMINADO` tinyint(1) NOT NULL DEFAULT 0,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_ASPIRANTE_DOCUMENTO`),
  KEY `FK_BBF_ASP_DOC_CARGADO_POR` (`ID_CARGADO_POR`),
  KEY `IDX_BBF_ASP_DOC_ASPIRANTE` (`ID_ASPIRANTE`),
  KEY `IDX_BBF_ASP_DOC_TIPO` (`ID_TIPO_DOCUMENTO_LABORAL`),
  CONSTRAINT `FK_BBF_ASP_DOC_ASPIRANTE` FOREIGN KEY (`ID_ASPIRANTE`) REFERENCES `bbf_aspirantes` (`ID_ASPIRANTE`),
  CONSTRAINT `FK_BBF_ASP_DOC_CARGADO_POR` FOREIGN KEY (`ID_CARGADO_POR`) REFERENCES `bbf_usuarios` (`ID_USUARIO`),
  CONSTRAINT `FK_BBF_ASP_DOC_TIPO` FOREIGN KEY (`ID_TIPO_DOCUMENTO_LABORAL`) REFERENCES `bbf_tipos_documento_laboral` (`ID_TIPO_DOCUMENTO_LABORAL`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_aspirante_documentos`
--

LOCK TABLES `bbf_aspirante_documentos` WRITE;
/*!40000 ALTER TABLE `bbf_aspirante_documentos` DISABLE KEYS */;
/*!40000 ALTER TABLE `bbf_aspirante_documentos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_aspirante_estado_historial`
--

DROP TABLE IF EXISTS `bbf_aspirante_estado_historial`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_aspirante_estado_historial` (
  `ID_HISTORIAL` int(11) NOT NULL AUTO_INCREMENT,
  `ID_ASPIRANTE` int(11) NOT NULL,
  `ESTADO_ANTERIOR` varchar(50) DEFAULT NULL,
  `ESTADO_NUEVO` varchar(50) NOT NULL,
  `OBSERVACIONES` text DEFAULT NULL,
  `ID_USUARIO_CAMBIO` int(11) DEFAULT NULL,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`ID_HISTORIAL`),
  KEY `FK_BBF_ASP_HIST_USUARIO` (`ID_USUARIO_CAMBIO`),
  KEY `IDX_BBF_ASP_HIST_ASPIRANTE` (`ID_ASPIRANTE`),
  CONSTRAINT `FK_BBF_ASP_HIST_ASPIRANTE` FOREIGN KEY (`ID_ASPIRANTE`) REFERENCES `bbf_aspirantes` (`ID_ASPIRANTE`),
  CONSTRAINT `FK_BBF_ASP_HIST_USUARIO` FOREIGN KEY (`ID_USUARIO_CAMBIO`) REFERENCES `bbf_usuarios` (`ID_USUARIO`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_aspirante_estado_historial`
--

LOCK TABLES `bbf_aspirante_estado_historial` WRITE;
/*!40000 ALTER TABLE `bbf_aspirante_estado_historial` DISABLE KEYS */;
/*!40000 ALTER TABLE `bbf_aspirante_estado_historial` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_aspirantes`
--

DROP TABLE IF EXISTS `bbf_aspirantes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_aspirantes` (
  `ID_ASPIRANTE` int(11) NOT NULL AUTO_INCREMENT,
  `ID_TIPO_DOCUMENTO` int(11) DEFAULT NULL,
  `NUMERO_DOCUMENTO` varchar(50) NOT NULL,
  `NOMBRES` varchar(150) NOT NULL,
  `APELLIDOS` varchar(150) NOT NULL,
  `CORREO` varchar(150) DEFAULT NULL,
  `TELEFONO` varchar(50) DEFAULT NULL,
  `DIRECCION` varchar(250) DEFAULT NULL,
  `FECHA_NACIMIENTO` date DEFAULT NULL,
  `ID_DEPARTAMENTO_NACIMIENTO` int(11) DEFAULT NULL,
  `ID_MUNICIPIO_NACIMIENTO` int(11) DEFAULT NULL,
  `LUGAR_NACIMIENTO` varchar(150) DEFAULT NULL,
  `DEPARTAMENTO_NACIMIENTO` varchar(150) DEFAULT NULL,
  `NACIONALIDAD` varchar(100) DEFAULT NULL,
  `ID_DEPARTAMENTO_RESIDENCIA` int(11) DEFAULT NULL,
  `ID_MUNICIPIO_RESIDENCIA` int(11) DEFAULT NULL,
  `CIUDAD_RESIDENCIA` varchar(150) DEFAULT NULL,
  `DEPARTAMENTO_RESIDENCIA` varchar(150) DEFAULT NULL,
  `ESTADO_CIVIL` enum('SOLTERO','CASADO','UNION_LIBRE','SEPARADO','DIVORCIADO','VIUDO','OTRO') DEFAULT NULL,
  `NIVEL_EDUCATIVO` enum('PRIMARIA','BACHILLER','TECNICO','TECNOLOGO','PROFESIONAL','POSGRADO','NINGUNO','OTRO') DEFAULT NULL,
  `PERSONAS_A_CARGO` int(11) DEFAULT 0,
  `NUMERO_HIJOS` int(11) DEFAULT 0,
  `ID_AREA_ASPIRA` int(11) DEFAULT NULL,
  `ID_CARGO_ASPIRA` int(11) DEFAULT NULL,
  `ESTADO_ASPIRANTE` enum('REGISTRADO','EN_REVISION','APROBADO_CONTRATACION','RECHAZADO','CONVERTIDO_EMPLEADO','CANCELADO') NOT NULL DEFAULT 'REGISTRADO',
  `OBSERVACIONES` text DEFAULT NULL,
  `ID_EMPLEADO_GENERADO` int(11) DEFAULT NULL,
  `ELIMINADO` tinyint(1) NOT NULL DEFAULT 0,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_ASPIRANTE`),
  UNIQUE KEY `UQ_BBF_ASPIRANTES_DOCUMENTO` (`NUMERO_DOCUMENTO`),
  KEY `FK_BBF_ASPIRANTES_TIPO_DOCUMENTO` (`ID_TIPO_DOCUMENTO`),
  KEY `FK_BBF_ASPIRANTES_CARGO` (`ID_CARGO_ASPIRA`),
  KEY `FK_BBF_ASPIRANTES_EMPLEADO_GENERADO` (`ID_EMPLEADO_GENERADO`),
  KEY `IDX_BBF_ASPIRANTES_ESTADO` (`ESTADO_ASPIRANTE`),
  KEY `IDX_BBF_ASPIRANTES_AREA_CARGO` (`ID_AREA_ASPIRA`,`ID_CARGO_ASPIRA`),
  KEY `FK_BBF_ASP_DEP_NAC` (`ID_DEPARTAMENTO_NACIMIENTO`),
  KEY `FK_BBF_ASP_MUN_NAC` (`ID_MUNICIPIO_NACIMIENTO`),
  KEY `FK_BBF_ASP_DEP_RES` (`ID_DEPARTAMENTO_RESIDENCIA`),
  KEY `FK_BBF_ASP_MUN_RES` (`ID_MUNICIPIO_RESIDENCIA`),
  CONSTRAINT `FK_BBF_ASPIRANTES_AREA` FOREIGN KEY (`ID_AREA_ASPIRA`) REFERENCES `bbf_areas` (`ID_AREA`),
  CONSTRAINT `FK_BBF_ASPIRANTES_CARGO` FOREIGN KEY (`ID_CARGO_ASPIRA`) REFERENCES `bbf_cargos` (`ID_CARGO`),
  CONSTRAINT `FK_BBF_ASPIRANTES_EMPLEADO_GENERADO` FOREIGN KEY (`ID_EMPLEADO_GENERADO`) REFERENCES `bbf_empleados` (`ID_EMPLEADO`),
  CONSTRAINT `FK_BBF_ASPIRANTES_TIPO_DOCUMENTO` FOREIGN KEY (`ID_TIPO_DOCUMENTO`) REFERENCES `bbf_tipos_documento` (`ID_TIPO_DOCUMENTO`),
  CONSTRAINT `FK_BBF_ASP_DEP_NAC` FOREIGN KEY (`ID_DEPARTAMENTO_NACIMIENTO`) REFERENCES `bbf_departamentos` (`ID_DEPARTAMENTO`),
  CONSTRAINT `FK_BBF_ASP_DEP_RES` FOREIGN KEY (`ID_DEPARTAMENTO_RESIDENCIA`) REFERENCES `bbf_departamentos` (`ID_DEPARTAMENTO`),
  CONSTRAINT `FK_BBF_ASP_MUN_NAC` FOREIGN KEY (`ID_MUNICIPIO_NACIMIENTO`) REFERENCES `bbf_municipios` (`ID_MUNICIPIO`),
  CONSTRAINT `FK_BBF_ASP_MUN_RES` FOREIGN KEY (`ID_MUNICIPIO_RESIDENCIA`) REFERENCES `bbf_municipios` (`ID_MUNICIPIO`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_aspirantes`
--

LOCK TABLES `bbf_aspirantes` WRITE;
/*!40000 ALTER TABLE `bbf_aspirantes` DISABLE KEYS */;
/*!40000 ALTER TABLE `bbf_aspirantes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_capacitacion_compromisos`
--

DROP TABLE IF EXISTS `bbf_capacitacion_compromisos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_capacitacion_compromisos` (
  `ID_CAPACITACION_COMPROMISO` int(11) NOT NULL AUTO_INCREMENT,
  `ID_CAPACITACION_RESULTADO` int(11) NOT NULL,
  `FECHA_COMPROMISO` date NOT NULL,
  `FECHA_LIMITE` date DEFAULT NULL,
  `MOTIVO` text NOT NULL,
  `COMPROMISOS_EMPLEADO` text DEFAULT NULL,
  `ESTADO` enum('BORRADOR','PENDIENTE_FIRMA','FIRMADO','CUMPLIDO','INCUMPLIDO','ANULADO') NOT NULL DEFAULT 'BORRADOR',
  `DOCUMENTO_URL` varchar(500) DEFAULT NULL,
  `DOCUMENTO_RUTA` varchar(500) DEFAULT NULL,
  `FIRMA_URL` varchar(500) DEFAULT NULL,
  `FECHA_FIRMA` datetime DEFAULT NULL,
  `OBSERVACIONES` text DEFAULT NULL,
  `ID_CREADO_POR` int(11) NOT NULL,
  `ID_CERRADO_POR` int(11) DEFAULT NULL,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_CAPACITACION_COMPROMISO`),
  UNIQUE KEY `UQ_BBF_CAP_COMPROMISO_RESULTADO` (`ID_CAPACITACION_RESULTADO`),
  KEY `IDX_BBF_CAP_COMPROMISO_ESTADO` (`ESTADO`,`FECHA_LIMITE`),
  KEY `FK_BBF_CAP_COMPROMISO_CREADO` (`ID_CREADO_POR`),
  KEY `FK_BBF_CAP_COMPROMISO_CERRADO` (`ID_CERRADO_POR`),
  CONSTRAINT `FK_BBF_CAP_COMPROMISO_CERRADO` FOREIGN KEY (`ID_CERRADO_POR`) REFERENCES `bbf_usuarios` (`ID_USUARIO`),
  CONSTRAINT `FK_BBF_CAP_COMPROMISO_CREADO` FOREIGN KEY (`ID_CREADO_POR`) REFERENCES `bbf_usuarios` (`ID_USUARIO`),
  CONSTRAINT `FK_BBF_CAP_COMPROMISO_RESULTADO` FOREIGN KEY (`ID_CAPACITACION_RESULTADO`) REFERENCES `bbf_capacitacion_resultados` (`ID_CAPACITACION_RESULTADO`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_capacitacion_compromisos`
--

LOCK TABLES `bbf_capacitacion_compromisos` WRITE;
/*!40000 ALTER TABLE `bbf_capacitacion_compromisos` DISABLE KEYS */;
INSERT INTO `bbf_capacitacion_compromisos` VALUES (1,1,'2026-08-11','2026-08-19','Resultado NO_APROBADO en la capacitación.',NULL,'BORRADOR',NULL,NULL,NULL,NULL,NULL,15,NULL,'2026-08-11 11:00:06',NULL);
/*!40000 ALTER TABLE `bbf_capacitacion_compromisos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_capacitacion_evaluaciones`
--

DROP TABLE IF EXISTS `bbf_capacitacion_evaluaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_capacitacion_evaluaciones` (
  `ID_CAPACITACION_EVALUACION` bigint(20) NOT NULL AUTO_INCREMENT,
  `ID_CAPACITACION_PARTICIPANTE` int(11) NOT NULL,
  `ID_CAPACITACION_LABOR` int(11) NOT NULL,
  `FECHA_EVALUACION` date NOT NULL,
  `VALOR_OBTENIDO` decimal(12,2) NOT NULL,
  `VALOR_MAXIMO` decimal(12,2) DEFAULT NULL,
  `REQUIERE_ATENCION` tinyint(1) NOT NULL DEFAULT 0,
  `OBSERVACIONES` varchar(500) DEFAULT NULL,
  `ID_EVALUADO_POR` int(11) NOT NULL,
  `ORIGEN` enum('MANUAL','EXCEL') NOT NULL DEFAULT 'MANUAL',
  `ID_CAPACITACION_IMPORTACION` bigint(20) DEFAULT NULL,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_CAPACITACION_EVALUACION`),
  UNIQUE KEY `UQ_BBF_CAP_EVAL_DIARIA` (`ID_CAPACITACION_PARTICIPANTE`,`ID_CAPACITACION_LABOR`,`FECHA_EVALUACION`),
  KEY `IDX_BBF_CAP_EVAL_FECHA` (`FECHA_EVALUACION`,`REQUIERE_ATENCION`),
  KEY `FK_BBF_CAP_EVAL_LABOR` (`ID_CAPACITACION_LABOR`),
  KEY `FK_BBF_CAP_EVAL_USUARIO` (`ID_EVALUADO_POR`),
  KEY `IDX_BBF_CAP_EVAL_IMPORT` (`ID_CAPACITACION_IMPORTACION`),
  CONSTRAINT `FK_BBF_CAP_EVAL_IMPORT` FOREIGN KEY (`ID_CAPACITACION_IMPORTACION`) REFERENCES `bbf_capacitacion_importaciones` (`ID_CAPACITACION_IMPORTACION`),
  CONSTRAINT `FK_BBF_CAP_EVAL_LABOR` FOREIGN KEY (`ID_CAPACITACION_LABOR`) REFERENCES `bbf_capacitacion_labores` (`ID_CAPACITACION_LABOR`),
  CONSTRAINT `FK_BBF_CAP_EVAL_PART` FOREIGN KEY (`ID_CAPACITACION_PARTICIPANTE`) REFERENCES `bbf_capacitacion_participantes` (`ID_CAPACITACION_PARTICIPANTE`),
  CONSTRAINT `FK_BBF_CAP_EVAL_USUARIO` FOREIGN KEY (`ID_EVALUADO_POR`) REFERENCES `bbf_usuarios` (`ID_USUARIO`),
  CONSTRAINT `CK_BBF_CAP_EVAL_VALORES` CHECK (`VALOR_OBTENIDO` >= 0 and (`VALOR_MAXIMO` is null or `VALOR_MAXIMO` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_capacitacion_evaluaciones`
--

LOCK TABLES `bbf_capacitacion_evaluaciones` WRITE;
/*!40000 ALTER TABLE `bbf_capacitacion_evaluaciones` DISABLE KEYS */;
/*!40000 ALTER TABLE `bbf_capacitacion_evaluaciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_capacitacion_evidencias`
--

DROP TABLE IF EXISTS `bbf_capacitacion_evidencias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_capacitacion_evidencias` (
  `ID_CAPACITACION_EVIDENCIA` bigint(20) NOT NULL AUTO_INCREMENT,
  `ID_CAPACITACION_SESION` int(11) DEFAULT NULL,
  `ID_CAPACITACION_PARTICIPANTE` int(11) DEFAULT NULL,
  `ID_CAPACITACION_COMPROMISO` int(11) DEFAULT NULL,
  `TIPO_EVIDENCIA` enum('ASISTENCIA','CONFIRMACION','EVALUACION','FIRMA','COMPROMISO','OTRA') NOT NULL,
  `NOMBRE_ARCHIVO` varchar(255) NOT NULL,
  `NOMBRE_ORIGINAL` varchar(255) DEFAULT NULL,
  `ARCHIVO_URL` varchar(500) DEFAULT NULL,
  `ARCHIVO_RUTA` varchar(500) DEFAULT NULL,
  `MIME_TYPE` varchar(100) DEFAULT NULL,
  `PESO_BYTES` bigint(20) DEFAULT NULL,
  `ID_CARGADO_POR` int(11) NOT NULL,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`ID_CAPACITACION_EVIDENCIA`),
  KEY `IDX_BBF_CAP_EVID_SESION` (`ID_CAPACITACION_SESION`),
  KEY `IDX_BBF_CAP_EVID_PART` (`ID_CAPACITACION_PARTICIPANTE`),
  KEY `IDX_BBF_CAP_EVID_COMP` (`ID_CAPACITACION_COMPROMISO`),
  KEY `FK_BBF_CAP_EVID_USUARIO` (`ID_CARGADO_POR`),
  CONSTRAINT `FK_BBF_CAP_EVID_COMP` FOREIGN KEY (`ID_CAPACITACION_COMPROMISO`) REFERENCES `bbf_capacitacion_compromisos` (`ID_CAPACITACION_COMPROMISO`),
  CONSTRAINT `FK_BBF_CAP_EVID_PART` FOREIGN KEY (`ID_CAPACITACION_PARTICIPANTE`) REFERENCES `bbf_capacitacion_participantes` (`ID_CAPACITACION_PARTICIPANTE`),
  CONSTRAINT `FK_BBF_CAP_EVID_SESION` FOREIGN KEY (`ID_CAPACITACION_SESION`) REFERENCES `bbf_capacitacion_sesiones` (`ID_CAPACITACION_SESION`),
  CONSTRAINT `FK_BBF_CAP_EVID_USUARIO` FOREIGN KEY (`ID_CARGADO_POR`) REFERENCES `bbf_usuarios` (`ID_USUARIO`),
  CONSTRAINT `CK_BBF_CAP_EVID_ORIGEN` CHECK (`ARCHIVO_URL` is not null or `ARCHIVO_RUTA` is not null)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_capacitacion_evidencias`
--

LOCK TABLES `bbf_capacitacion_evidencias` WRITE;
/*!40000 ALTER TABLE `bbf_capacitacion_evidencias` DISABLE KEYS */;
/*!40000 ALTER TABLE `bbf_capacitacion_evidencias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_capacitacion_importacion_errores`
--

DROP TABLE IF EXISTS `bbf_capacitacion_importacion_errores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_capacitacion_importacion_errores` (
  `ID_CAPACITACION_IMPORTACION_ERROR` bigint(20) NOT NULL AUTO_INCREMENT,
  `ID_CAPACITACION_IMPORTACION` bigint(20) NOT NULL,
  `HOJA` varchar(150) DEFAULT NULL,
  `CELDA` varchar(30) DEFAULT NULL,
  `FILA` int(11) DEFAULT NULL,
  `EMPLEADO_ORIGINAL` varchar(250) DEFAULT NULL,
  `LABOR_ORIGINAL` varchar(250) DEFAULT NULL,
  `VALOR_ORIGINAL` varchar(500) DEFAULT NULL,
  `CODIGO_ERROR` varchar(80) NOT NULL,
  `MENSAJE` varchar(500) NOT NULL,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`ID_CAPACITACION_IMPORTACION_ERROR`),
  KEY `IDX_BBF_CAP_IMPORT_ERROR_IMPORT` (`ID_CAPACITACION_IMPORTACION`,`FILA`),
  CONSTRAINT `FK_BBF_CAP_IMPORT_ERROR_IMPORT` FOREIGN KEY (`ID_CAPACITACION_IMPORTACION`) REFERENCES `bbf_capacitacion_importaciones` (`ID_CAPACITACION_IMPORTACION`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_capacitacion_importacion_errores`
--

LOCK TABLES `bbf_capacitacion_importacion_errores` WRITE;
/*!40000 ALTER TABLE `bbf_capacitacion_importacion_errores` DISABLE KEYS */;
/*!40000 ALTER TABLE `bbf_capacitacion_importacion_errores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_capacitacion_importaciones`
--

DROP TABLE IF EXISTS `bbf_capacitacion_importaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_capacitacion_importaciones` (
  `ID_CAPACITACION_IMPORTACION` bigint(20) NOT NULL AUTO_INCREMENT,
  `ID_CAPACITACION_SESION` int(11) DEFAULT NULL,
  `NOMBRE_ARCHIVO` varchar(255) NOT NULL,
  `NOMBRE_ORIGINAL` varchar(255) NOT NULL,
  `ARCHIVO_RUTA` varchar(500) NOT NULL,
  `MIME_TYPE` varchar(100) DEFAULT NULL,
  `PESO_BYTES` bigint(20) DEFAULT NULL,
  `ESTADO` enum('CARGADA','VALIDANDO','CON_ERRORES','VALIDADA','IMPORTADA','ANULADA') NOT NULL DEFAULT 'CARGADA',
  `TOTAL_REGISTROS` int(11) NOT NULL DEFAULT 0,
  `TOTAL_VALIDOS` int(11) NOT NULL DEFAULT 0,
  `TOTAL_ERRORES` int(11) NOT NULL DEFAULT 0,
  `RESUMEN` text DEFAULT NULL,
  `ID_CARGADO_POR` int(11) NOT NULL,
  `FECHA_IMPORTACION` datetime DEFAULT NULL,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_CAPACITACION_IMPORTACION`),
  KEY `IDX_BBF_CAP_IMPORT_ESTADO` (`ESTADO`,`CREATED_AT`),
  KEY `FK_BBF_CAP_IMPORT_SESION` (`ID_CAPACITACION_SESION`),
  KEY `FK_BBF_CAP_IMPORT_USUARIO` (`ID_CARGADO_POR`),
  CONSTRAINT `FK_BBF_CAP_IMPORT_SESION` FOREIGN KEY (`ID_CAPACITACION_SESION`) REFERENCES `bbf_capacitacion_sesiones` (`ID_CAPACITACION_SESION`),
  CONSTRAINT `FK_BBF_CAP_IMPORT_USUARIO` FOREIGN KEY (`ID_CARGADO_POR`) REFERENCES `bbf_usuarios` (`ID_USUARIO`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_capacitacion_importaciones`
--

LOCK TABLES `bbf_capacitacion_importaciones` WRITE;
/*!40000 ALTER TABLE `bbf_capacitacion_importaciones` DISABLE KEYS */;
/*!40000 ALTER TABLE `bbf_capacitacion_importaciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_capacitacion_labor_detalle`
--

DROP TABLE IF EXISTS `bbf_capacitacion_labor_detalle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_capacitacion_labor_detalle` (
  `ID_CAPACITACION_LABOR_DETALLE` int(11) NOT NULL AUTO_INCREMENT,
  `ID_CAPACITACION` int(11) NOT NULL,
  `ID_CAPACITACION_LABOR` int(11) NOT NULL,
  `PUNTAJE_MINIMO_LABOR` decimal(10,2) DEFAULT NULL,
  `PUNTAJE_MAXIMO_LABOR` decimal(10,2) DEFAULT NULL,
  `ORDEN` int(11) NOT NULL DEFAULT 0,
  `ACTIVO` tinyint(1) NOT NULL DEFAULT 1,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_CAPACITACION_LABOR_DETALLE`),
  UNIQUE KEY `UQ_BBF_CAP_LABOR_DETALLE` (`ID_CAPACITACION`,`ID_CAPACITACION_LABOR`),
  KEY `FK_BBF_CAP_LAB_DET_LABOR` (`ID_CAPACITACION_LABOR`),
  CONSTRAINT `FK_BBF_CAP_LAB_DET_CAP` FOREIGN KEY (`ID_CAPACITACION`) REFERENCES `bbf_capacitaciones` (`ID_CAPACITACION`),
  CONSTRAINT `FK_BBF_CAP_LAB_DET_LABOR` FOREIGN KEY (`ID_CAPACITACION_LABOR`) REFERENCES `bbf_capacitacion_labores` (`ID_CAPACITACION_LABOR`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_capacitacion_labor_detalle`
--

LOCK TABLES `bbf_capacitacion_labor_detalle` WRITE;
/*!40000 ALTER TABLE `bbf_capacitacion_labor_detalle` DISABLE KEYS */;
INSERT INTO `bbf_capacitacion_labor_detalle` VALUES (13,2,1,NULL,NULL,1,1,'2026-08-10 16:20:27',NULL),(14,2,2,NULL,NULL,2,1,'2026-08-10 16:20:27',NULL),(15,2,3,NULL,NULL,3,1,'2026-08-10 16:20:27',NULL),(16,2,4,NULL,NULL,4,1,'2026-08-10 16:20:27',NULL),(17,2,5,NULL,NULL,5,1,'2026-08-10 16:20:27',NULL),(18,2,6,NULL,NULL,6,1,'2026-08-10 16:20:27',NULL),(19,2,7,NULL,NULL,7,1,'2026-08-10 16:20:27',NULL),(20,2,8,NULL,NULL,8,1,'2026-08-10 16:20:27',NULL),(21,2,9,NULL,NULL,9,1,'2026-08-10 16:20:27',NULL),(22,2,10,NULL,NULL,10,1,'2026-08-10 16:20:27',NULL),(23,2,11,NULL,NULL,11,1,'2026-08-10 16:20:27',NULL),(24,2,12,NULL,NULL,12,1,'2026-08-10 16:20:27',NULL);
/*!40000 ALTER TABLE `bbf_capacitacion_labor_detalle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_capacitacion_labores`
--

DROP TABLE IF EXISTS `bbf_capacitacion_labores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_capacitacion_labores` (
  `ID_CAPACITACION_LABOR` int(11) NOT NULL AUTO_INCREMENT,
  `CODIGO` varchar(50) NOT NULL,
  `NOMBRE` varchar(150) NOT NULL,
  `DESCRIPCION` varchar(500) DEFAULT NULL,
  `ORDEN` int(11) NOT NULL DEFAULT 0,
  `ACTIVO` tinyint(1) NOT NULL DEFAULT 1,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_CAPACITACION_LABOR`),
  UNIQUE KEY `UQ_BBF_CAP_LABORES_CODIGO` (`CODIGO`),
  UNIQUE KEY `UQ_BBF_CAP_LABORES_NOMBRE` (`NOMBRE`),
  KEY `IDX_BBF_CAP_LABORES_ACTIVO_ORDEN` (`ACTIVO`,`ORDEN`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_capacitacion_labores`
--

LOCK TABLES `bbf_capacitacion_labores` WRITE;
/*!40000 ALTER TABLE `bbf_capacitacion_labores` DISABLE KEYS */;
INSERT INTO `bbf_capacitacion_labores` VALUES (1,'DESBOTONE','Desbotone',NULL,1,1,'2026-08-03 16:40:02',NULL),(2,'PINCH','Pinch',NULL,2,1,'2026-08-03 16:40:02',NULL),(3,'GUIADA_TALLOS','Guiada de tallos',NULL,3,1,'2026-08-03 16:40:02',NULL),(4,'PROGRAMACIONES','Programaciones',NULL,4,1,'2026-08-03 16:40:02',NULL),(5,'DESHIERBE','Deshierbe',NULL,5,1,'2026-08-03 16:40:02',NULL),(6,'DESCHUPONADO','Deschuponado',NULL,6,1,'2026-08-03 16:40:02',NULL),(7,'BARRIDA','Barrida',NULL,7,1,'2026-08-03 16:40:02',NULL),(8,'PALO_SECO','Palo seco',NULL,8,1,'2026-08-03 16:40:02',NULL),(9,'ENMALLE','Enmalle',NULL,9,1,'2026-08-03 16:40:02',NULL),(10,'SELECCION_BROTES','Seleccion de brotes',NULL,10,1,'2026-08-03 16:40:02',NULL),(11,'ENTRESAQUE','Entresaque',NULL,11,1,'2026-08-03 16:40:02',NULL),(12,'REPORTES_FITOSANITARIOS','Reportes fitosanitarios',NULL,12,1,'2026-08-03 16:40:02',NULL);
/*!40000 ALTER TABLE `bbf_capacitacion_labores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_capacitacion_participantes`
--

DROP TABLE IF EXISTS `bbf_capacitacion_participantes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_capacitacion_participantes` (
  `ID_CAPACITACION_PARTICIPANTE` int(11) NOT NULL AUTO_INCREMENT,
  `ID_CAPACITACION_SESION` int(11) NOT NULL,
  `ID_EMPLEADO` int(11) NOT NULL,
  `ESTADO_ASISTENCIA` enum('PENDIENTE','ASISTIO','NO_ASISTIO','JUSTIFICADO','INCAPACITADO') NOT NULL DEFAULT 'PENDIENTE',
  `CONFIRMO_RECIBIDO` tinyint(1) NOT NULL DEFAULT 0,
  `FECHA_CONFIRMACION` datetime DEFAULT NULL,
  `ID_CONFIRMADO_POR` int(11) DEFAULT NULL,
  `MODALIDAD_CONFIRMACION` enum('EMPLEADO','PRESENCIAL_RRHH') DEFAULT NULL,
  `OBSERVACION_CONFIRMACION` varchar(500) DEFAULT NULL,
  `ESTADO_EVALUACION` enum('PENDIENTE','EN_PROCESO','EVALUADA','NO_APLICA') NOT NULL DEFAULT 'PENDIENTE',
  `OBSERVACIONES` text DEFAULT NULL,
  `ID_REGISTRADO_POR` int(11) NOT NULL,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_CAPACITACION_PARTICIPANTE`),
  UNIQUE KEY `UQ_BBF_CAP_PARTICIPANTE` (`ID_CAPACITACION_SESION`,`ID_EMPLEADO`),
  KEY `IDX_BBF_CAP_PART_EMPLEADO` (`ID_EMPLEADO`,`ESTADO_EVALUACION`),
  KEY `FK_BBF_CAP_PART_CONFIRMADO` (`ID_CONFIRMADO_POR`),
  KEY `FK_BBF_CAP_PART_REGISTRADO` (`ID_REGISTRADO_POR`),
  CONSTRAINT `FK_BBF_CAP_PART_CONFIRMADO` FOREIGN KEY (`ID_CONFIRMADO_POR`) REFERENCES `bbf_usuarios` (`ID_USUARIO`),
  CONSTRAINT `FK_BBF_CAP_PART_EMPLEADO` FOREIGN KEY (`ID_EMPLEADO`) REFERENCES `bbf_empleados` (`ID_EMPLEADO`),
  CONSTRAINT `FK_BBF_CAP_PART_REGISTRADO` FOREIGN KEY (`ID_REGISTRADO_POR`) REFERENCES `bbf_usuarios` (`ID_USUARIO`),
  CONSTRAINT `FK_BBF_CAP_PART_SESION` FOREIGN KEY (`ID_CAPACITACION_SESION`) REFERENCES `bbf_capacitacion_sesiones` (`ID_CAPACITACION_SESION`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_capacitacion_participantes`
--

LOCK TABLES `bbf_capacitacion_participantes` WRITE;
/*!40000 ALTER TABLE `bbf_capacitacion_participantes` DISABLE KEYS */;
INSERT INTO `bbf_capacitacion_participantes` VALUES (1,1,3,'PENDIENTE',0,NULL,NULL,NULL,NULL,'PENDIENTE',NULL,15,'2026-08-11 10:53:35',NULL),(2,2,3,'PENDIENTE',0,NULL,NULL,NULL,NULL,'PENDIENTE',NULL,15,'2026-08-11 10:53:47',NULL),(3,2,4,'PENDIENTE',0,NULL,NULL,NULL,NULL,'EVALUADA',NULL,15,'2026-08-11 10:59:11','2026-08-11 10:59:56');
/*!40000 ALTER TABLE `bbf_capacitacion_participantes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_capacitacion_resultados`
--

DROP TABLE IF EXISTS `bbf_capacitacion_resultados`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_capacitacion_resultados` (
  `ID_CAPACITACION_RESULTADO` int(11) NOT NULL AUTO_INCREMENT,
  `ID_CAPACITACION_PARTICIPANTE` int(11) NOT NULL,
  `FECHA_RESULTADO` date NOT NULL,
  `TOTAL_ACUMULADO` decimal(14,2) DEFAULT NULL,
  `PUNTAJE_FINAL` decimal(10,2) DEFAULT NULL,
  `PUNTAJE_MINIMO_APLICADO` decimal(10,2) DEFAULT NULL,
  `RESULTADO` enum('PENDIENTE','APROBADO','NO_APROBADO','REQUIERE_REINDUCCION') NOT NULL DEFAULT 'PENDIENTE',
  `REQUIERE_REINDUCCION` tinyint(1) NOT NULL DEFAULT 0,
  `REQUIERE_COMPROMISO` tinyint(1) NOT NULL DEFAULT 0,
  `REGLA_APLICADA` varchar(500) DEFAULT NULL,
  `OBSERVACIONES` text DEFAULT NULL,
  `ID_REGISTRADO_POR` int(11) NOT NULL,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_CAPACITACION_RESULTADO`),
  UNIQUE KEY `UQ_BBF_CAP_RESULTADO_PART` (`ID_CAPACITACION_PARTICIPANTE`),
  KEY `IDX_BBF_CAP_RESULTADO_ALERTA` (`RESULTADO`,`REQUIERE_COMPROMISO`),
  KEY `FK_BBF_CAP_RESULTADO_USUARIO` (`ID_REGISTRADO_POR`),
  CONSTRAINT `FK_BBF_CAP_RESULTADO_PART` FOREIGN KEY (`ID_CAPACITACION_PARTICIPANTE`) REFERENCES `bbf_capacitacion_participantes` (`ID_CAPACITACION_PARTICIPANTE`),
  CONSTRAINT `FK_BBF_CAP_RESULTADO_USUARIO` FOREIGN KEY (`ID_REGISTRADO_POR`) REFERENCES `bbf_usuarios` (`ID_USUARIO`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_capacitacion_resultados`
--

LOCK TABLES `bbf_capacitacion_resultados` WRITE;
/*!40000 ALTER TABLE `bbf_capacitacion_resultados` DISABLE KEYS */;
INSERT INTO `bbf_capacitacion_resultados` VALUES (1,3,'2026-08-11',0.00,2.00,NULL,'NO_APROBADO',0,1,NULL,NULL,15,'2026-08-11 10:59:28','2026-08-11 11:00:06');
/*!40000 ALTER TABLE `bbf_capacitacion_resultados` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_capacitacion_sesiones`
--

DROP TABLE IF EXISTS `bbf_capacitacion_sesiones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_capacitacion_sesiones` (
  `ID_CAPACITACION_SESION` int(11) NOT NULL AUTO_INCREMENT,
  `ID_CAPACITACION` int(11) NOT NULL,
  `CODIGO` varchar(60) NOT NULL,
  `FECHA_INICIO` date NOT NULL,
  `FECHA_FIN` date NOT NULL,
  `ANIO_ISO` smallint(6) NOT NULL,
  `SEMANA_ISO` tinyint(4) NOT NULL,
  `ID_INSTRUCTOR_USUARIO` int(11) DEFAULT NULL,
  `INSTRUCTOR_EXTERNO` varchar(200) DEFAULT NULL,
  `LUGAR` varchar(250) DEFAULT NULL,
  `ESTADO` enum('BORRADOR','PROGRAMADA','EN_EJECUCION','CERRADA','ANULADA') NOT NULL DEFAULT 'BORRADOR',
  `OBSERVACIONES` text DEFAULT NULL,
  `FECHA_CIERRE` datetime DEFAULT NULL,
  `ID_CREADO_POR` int(11) NOT NULL,
  `ID_CERRADO_POR` int(11) DEFAULT NULL,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_CAPACITACION_SESION`),
  UNIQUE KEY `UQ_BBF_CAP_SESIONES_CODIGO` (`CODIGO`),
  UNIQUE KEY `UQ_BBF_CAP_SESION_PERIODO` (`ID_CAPACITACION`,`FECHA_INICIO`,`FECHA_FIN`),
  KEY `IDX_BBF_CAP_SESIONES_PERIODO` (`ANIO_ISO`,`SEMANA_ISO`,`ESTADO`),
  KEY `FK_BBF_CAP_SESIONES_INSTRUCTOR` (`ID_INSTRUCTOR_USUARIO`),
  KEY `FK_BBF_CAP_SESIONES_CREADO` (`ID_CREADO_POR`),
  KEY `FK_BBF_CAP_SESIONES_CERRADO` (`ID_CERRADO_POR`),
  CONSTRAINT `FK_BBF_CAP_SESIONES_CAP` FOREIGN KEY (`ID_CAPACITACION`) REFERENCES `bbf_capacitaciones` (`ID_CAPACITACION`),
  CONSTRAINT `FK_BBF_CAP_SESIONES_CERRADO` FOREIGN KEY (`ID_CERRADO_POR`) REFERENCES `bbf_usuarios` (`ID_USUARIO`),
  CONSTRAINT `FK_BBF_CAP_SESIONES_CREADO` FOREIGN KEY (`ID_CREADO_POR`) REFERENCES `bbf_usuarios` (`ID_USUARIO`),
  CONSTRAINT `FK_BBF_CAP_SESIONES_INSTRUCTOR` FOREIGN KEY (`ID_INSTRUCTOR_USUARIO`) REFERENCES `bbf_usuarios` (`ID_USUARIO`),
  CONSTRAINT `CK_BBF_CAP_SESIONES_FECHAS` CHECK (`FECHA_FIN` >= `FECHA_INICIO`),
  CONSTRAINT `CK_BBF_CAP_SESIONES_SEMANA` CHECK (`SEMANA_ISO` between 1 and 53)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_capacitacion_sesiones`
--

LOCK TABLES `bbf_capacitacion_sesiones` WRITE;
/*!40000 ALTER TABLE `bbf_capacitacion_sesiones` DISABLE KEYS */;
INSERT INTO `bbf_capacitacion_sesiones` VALUES (1,2,'CAP-2-202631-0801','2026-08-01','2026-08-08',2026,31,NULL,'Pepito','local','BORRADOR','na',NULL,15,NULL,'2026-08-11 10:53:09',NULL),(2,2,'CAP-2-202632-0809','2026-08-09','2026-08-15',2026,32,NULL,'Pepito','local','BORRADOR','na',NULL,15,NULL,'2026-08-11 10:53:28',NULL);
/*!40000 ALTER TABLE `bbf_capacitacion_sesiones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_capacitaciones`
--

DROP TABLE IF EXISTS `bbf_capacitaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_capacitaciones` (
  `ID_CAPACITACION` int(11) NOT NULL AUTO_INCREMENT,
  `CODIGO` varchar(50) NOT NULL,
  `NOMBRE` varchar(200) NOT NULL,
  `DESCRIPCION` text DEFAULT NULL,
  `TIPO` enum('CAPACITACION','INDUCCION','REINDUCCION','EVALUACION_REINDUCCION') NOT NULL DEFAULT 'CAPACITACION',
  `REQUIERE_EVALUACION` tinyint(1) NOT NULL DEFAULT 1,
  `REQUIERE_CONFIRMACION` tinyint(1) NOT NULL DEFAULT 1,
  `PUNTAJE_MINIMO` decimal(10,2) DEFAULT NULL,
  `PUNTAJE_MAXIMO` decimal(10,2) DEFAULT NULL,
  `REGLA_CALCULO` varchar(500) DEFAULT NULL,
  `GENERAR_COMPROMISO_NO_APROBADO` tinyint(1) NOT NULL DEFAULT 0,
  `DIAS_PARA_EVALUAR` int(11) DEFAULT NULL,
  `ACTIVO` tinyint(1) NOT NULL DEFAULT 1,
  `ID_CREADO_POR` int(11) NOT NULL,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_CAPACITACION`),
  UNIQUE KEY `UQ_BBF_CAPACITACIONES_CODIGO` (`CODIGO`),
  KEY `IDX_BBF_CAPACITACIONES_TIPO_ACTIVO` (`TIPO`,`ACTIVO`),
  KEY `FK_BBF_CAPACITACIONES_CREADO_POR` (`ID_CREADO_POR`),
  CONSTRAINT `FK_BBF_CAPACITACIONES_CREADO_POR` FOREIGN KEY (`ID_CREADO_POR`) REFERENCES `bbf_usuarios` (`ID_USUARIO`),
  CONSTRAINT `CK_BBF_CAPACITACIONES_PUNTAJES` CHECK ((`PUNTAJE_MINIMO` is null or `PUNTAJE_MINIMO` >= 0) and (`PUNTAJE_MAXIMO` is null or `PUNTAJE_MAXIMO` > 0) and (`PUNTAJE_MINIMO` is null or `PUNTAJE_MAXIMO` is null or `PUNTAJE_MINIMO` <= `PUNTAJE_MAXIMO`))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_capacitaciones`
--

LOCK TABLES `bbf_capacitaciones` WRITE;
/*!40000 ALTER TABLE `bbf_capacitaciones` DISABLE KEYS */;
INSERT INTO `bbf_capacitaciones` VALUES (2,'EVAL_REIND_CULTIVO','Evaluación y reinducción de labores de cultivo','Evaluación y reinducción semanal de labores de cultivo.','EVALUACION_REINDUCCION',1,1,NULL,NULL,'El acumulado y el puntaje final se registran por separado.',0,NULL,1,15,'2026-08-10 16:10:13',NULL);
/*!40000 ALTER TABLE `bbf_capacitaciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_cargos`
--

DROP TABLE IF EXISTS `bbf_cargos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_cargos` (
  `ID_CARGO` int(11) NOT NULL AUTO_INCREMENT,
  `NOMBRE` varchar(150) NOT NULL,
  `DESCRIPCION` text DEFAULT NULL,
  `ACTIVO` tinyint(1) NOT NULL DEFAULT 1,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_CARGO`),
  UNIQUE KEY `UQ_BBF_CARGOS_NOMBRE` (`NOMBRE`)
) ENGINE=InnoDB AUTO_INCREMENT=54 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_cargos`
--

LOCK TABLES `bbf_cargos` WRITE;
/*!40000 ALTER TABLE `bbf_cargos` DISABLE KEYS */;
INSERT INTO `bbf_cargos` VALUES (3,'Administrador','Responsable de la administración general del sistema o empresa',1,'2026-06-23 10:00:15',NULL),(4,'Auxiliar de Recursos Humanos','Apoyo en procesos administrativos de personal',1,'2026-06-23 10:00:15',NULL),(5,'Jefe de Recursos Humanos','Responsable del área de talento humano',1,'2026-06-23 10:00:15',NULL),(6,'Supervisor','Responsable de supervisión de personal y procesos',1,'2026-06-23 10:00:15',NULL),(7,'Supervisor de Calidad','Responsable de control y seguimiento de calidad',1,'2026-06-23 10:00:15','2026-08-10 10:51:14'),(8,'Operario','Personal operativo general',1,'2026-06-23 10:00:15','2026-08-10 10:51:14'),(9,'Operario de Cultivo','Personal encargado de labores de cultivo',1,'2026-06-23 10:00:15',NULL),(10,'Operario de Poscosecha','Personal encargado de labores de poscosecha',1,'2026-06-23 10:00:15',NULL),(11,'Vendedor','Responsable de gestión comercial y clientes',1,'2026-06-23 10:00:15',NULL),(12,'Auxiliar Administrativo','Apoyo en tareas administrativas',1,'2026-06-23 10:00:15','2026-08-10 10:51:14'),(13,'Conductor','Responsable de transporte y entregas',1,'2026-06-23 10:00:15',NULL),(14,'Técnico de Mantenimiento','Responsable de mantenimiento de equipos e infraestructura',1,'2026-06-23 10:00:15',NULL),(43,'Asesor Legal','Cargo recibido en la base inicial del cliente.',1,'2026-08-10 10:51:14',NULL),(44,'Gerente general','Cargo recibido en la base inicial del cliente.',1,'2026-08-10 10:51:14',NULL),(45,'Jefe de poscosecha','Cargo recibido en la base inicial del cliente.',1,'2026-08-10 10:51:14',NULL),(46,'Coordinador administrativo','Cargo recibido en la base inicial del cliente.',1,'2026-08-10 10:51:14',NULL),(47,'Coordinador contable','Cargo recibido en la base inicial del cliente.',1,'2026-08-10 10:51:14',NULL),(48,'Jardinero','Cargo recibido en la base inicial del cliente.',1,'2026-08-10 10:51:14',NULL),(49,'Monitor','Cargo recibido en la base inicial del cliente.',1,'2026-08-10 10:51:14',NULL),(50,'Pasante del SENA','Cargo recibido en la base inicial del cliente.',1,'2026-08-10 10:51:14',NULL),(51,'Servicios generales','Cargo recibido en la base inicial del cliente.',1,'2026-08-10 10:51:14',NULL),(52,'Supervisor de poscosecha','Cargo recibido en la base inicial del cliente.',1,'2026-08-10 10:51:14',NULL),(53,'Supervisor general','Cargo recibido en la base inicial del cliente.',1,'2026-08-10 10:51:14',NULL);
/*!40000 ALTER TABLE `bbf_cargos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_contrato_plantillas`
--

DROP TABLE IF EXISTS `bbf_contrato_plantillas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_contrato_plantillas` (
  `ID_PLANTILLA_CONTRATO` int(11) NOT NULL AUTO_INCREMENT,
  `ID_TIPO_CONTRATO` int(11) NOT NULL,
  `NOMBRE_PLANTILLA` varchar(200) NOT NULL,
  `CODIGO_FORMATO` varchar(50) NOT NULL,
  `VERSION_FORMATO` varchar(20) NOT NULL,
  `FECHA_VIGENCIA` date DEFAULT NULL,
  `TIPO_CARGO_CONTRATO` enum('ADMINISTRATIVO','OPERATIVO','OTRO') DEFAULT NULL,
  `DESCRIPCION` text DEFAULT NULL,
  `ARCHIVO_PLANTILLA_URL` varchar(500) DEFAULT NULL,
  `ARCHIVO_PLANTILLA_RUTA` varchar(500) DEFAULT NULL,
  `FORMATO_SALIDA_DEFAULT` enum('DOCX','PDF','AMBOS') NOT NULL DEFAULT 'PDF',
  `CONFIG_CAMPOS_JSON` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`CONFIG_CAMPOS_JSON`)),
  `VALORES_DEFAULT_JSON` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`VALORES_DEFAULT_JSON`)),
  `ACTIVO` tinyint(1) NOT NULL DEFAULT 1,
  `ELIMINADO` tinyint(1) NOT NULL DEFAULT 0,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_PLANTILLA_CONTRATO`),
  KEY `IDX_BBF_CONTRATO_PLANTILLA_TIPO` (`ID_TIPO_CONTRATO`),
  KEY `IDX_BBF_CONTRATO_PLANTILLA_CARGO` (`TIPO_CARGO_CONTRATO`),
  KEY `IDX_BBF_CONTRATO_PLANTILLA_ACTIVO` (`ACTIVO`,`ELIMINADO`),
  CONSTRAINT `FK_BBF_CONTRATO_PLANTILLA_TIPO` FOREIGN KEY (`ID_TIPO_CONTRATO`) REFERENCES `bbf_tipos_contrato` (`ID_TIPO_CONTRATO`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_contrato_plantillas`
--

LOCK TABLES `bbf_contrato_plantillas` WRITE;
/*!40000 ALTER TABLE `bbf_contrato_plantillas` DISABLE KEYS */;
INSERT INTO `bbf_contrato_plantillas` VALUES (1,3,'Contrato laboral a término fijo inferior a un año - Administrativo','BBTH-F-015','02','2026-06-18','ADMINISTRATIVO','Plantilla para contrato laboral a término fijo inferior a un año administrativa.',NULL,'contract-templates/BBTH-F-015-PLANTILLA-CONTRATO-TERMINO-FIJO-INFERIOR-A-UN-ANO.docx','PDF','{\"requiere_fecha_fin\": true, \"requiere_duracion_meses\": true, \"requiere_prorroga_dias\": false, \"requiere_objeto_obra_labor\": false, \"requiere_periodo_prueba_dias\": true, \"requiere_clausula_funciones\": true, \"campos_visibles\": [\"id_empleado\", \"id_tipo_contrato\", \"id_plantilla_contrato\", \"id_area\", \"id_cargo\", \"fecha_inicio\", \"fecha_fin\", \"duracion_meses\", \"salario_base\", \"auxilio_transporte\", \"periodo_pago\", \"lugar_labores\", \"numero_contrato\", \"tipo_cargo_contrato\", \"clausula_funciones\", \"jornada_laboral\", \"periodo_prueba_dias\", \"observaciones\"], \"campos_ocultos\": [\"objeto_obra_labor\", \"prorroga_dias\"]}','{\"auxilio_transporte\": true, \"periodo_pago\": \"QUINCENALES\", \"lugar_labores\": \"VEREDA SAN JOSE, FINCA BARRO BLANCO\", \"tipo_cargo_contrato\": \"ADMINISTRATIVO\", \"duracion_meses\": 3, \"jornada_laboral\": \"44 horas semanales efectivas de labor\", \"periodo_prueba_dias\": 60, \"termino_inicial_contrato\": \"TRES (03) MESES\", \"salario_texto_default\": \"SALARIO MINIMO LEGAL VIGENTE\"}',1,0,'2026-07-09 18:26:46','2026-07-09 19:41:24'),(2,4,'Contrato por obra o labor determinada - Operativa','BBTH-F-014','02','2026-06-18','OPERATIVO','Plantilla para contrato por obra o labor determinada operativa.',NULL,'contract-templates/BBTH-F-014-PLANTILLA-CONTRATO-OBRA-O-LABOR-DETERMINADA.docx','PDF','{\"requiere_fecha_fin\": true, \"requiere_duracion_meses\": false, \"requiere_prorroga_dias\": true, \"requiere_objeto_obra_labor\": true, \"requiere_periodo_prueba_dias\": false, \"requiere_clausula_funciones\": true, \"campos_visibles\": [\"id_empleado\", \"id_tipo_contrato\", \"id_plantilla_contrato\", \"id_area\", \"id_cargo\", \"fecha_inicio\", \"fecha_fin\", \"salario_base\", \"auxilio_transporte\", \"periodo_pago\", \"lugar_labores\", \"numero_contrato\", \"tipo_cargo_contrato\", \"objeto_obra_labor\", \"prorroga_dias\", \"clausula_funciones\", \"jornada_laboral\", \"observaciones\"], \"campos_ocultos\": [\"duracion_meses\", \"periodo_prueba_dias\"]}','{\"auxilio_transporte\": true, \"periodo_pago\": \"Quincenales\", \"lugar_labores\": \"VEREDA SAN JOSE, FINCA BARRO BLANCO\", \"tipo_cargo_contrato\": \"OPERATIVO\", \"objeto_obra_labor\": \"Realizar labores relacionadas con floricultura.\", \"prorroga_dias\": 0, \"jornada_laboral\": \"44 horas semanales efectivas de labor\", \"termino_inicial_contrato\": \"30 DIAS\", \"salario_texto_default\": \"SMLV\"}',1,0,'2026-07-09 18:26:46','2026-07-09 19:41:16'),(3,2,'Contrato de trabajo a término indefinido','BBTH-7','02','2026-06-18','ADMINISTRATIVO','Plantilla para contrato individual de trabajo a término indefinido.',NULL,'contract-templates/BBTH-F-016-PLANTILLA-CONTRATO-TERMINO-INDEFINIDO.docx','PDF','{\"requiere_fecha_fin\": false, \"requiere_duracion_meses\": false, \"requiere_prorroga_dias\": false, \"requiere_objeto_obra_labor\": false, \"requiere_periodo_prueba_dias\": true, \"requiere_clausula_funciones\": false, \"campos_visibles\": [\"id_empleado\", \"id_tipo_contrato\", \"id_plantilla_contrato\", \"id_area\", \"id_cargo\", \"fecha_inicio\", \"salario_base\", \"auxilio_transporte\", \"periodo_pago\", \"lugar_labores\", \"numero_contrato\", \"tipo_cargo_contrato\", \"jornada_laboral\", \"periodo_prueba_dias\", \"observaciones\"], \"campos_ocultos\": [\"fecha_fin\", \"duracion_meses\", \"objeto_obra_labor\", \"prorroga_dias\", \"clausula_funciones\"]}','{\"auxilio_transporte\": true, \"periodo_pago\": \"Quincenales\", \"lugar_labores\": \"FINCA BARRO BLANCO GACHANCIPA\", \"tipo_cargo_contrato\": \"ADMINISTRATIVO\", \"jornada_laboral\": \"44 horas semanales efectivas de labor\", \"periodo_prueba_dias\": 60, \"termino_inicial_contrato\": \"INDEFINIDO\", \"salario_texto_default\": \"MINIMO LEGAL VIGENTE\"}',1,0,'2026-07-09 18:26:46','2026-07-09 19:41:24');
/*!40000 ALTER TABLE `bbf_contrato_plantillas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_departamentos`
--

DROP TABLE IF EXISTS `bbf_departamentos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_departamentos` (
  `ID_DEPARTAMENTO` int(11) NOT NULL AUTO_INCREMENT,
  `CODIGO_DANE` varchar(2) NOT NULL,
  `NOMBRE` varchar(150) NOT NULL,
  `ACTIVO` tinyint(1) NOT NULL DEFAULT 1,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_DEPARTAMENTO`),
  UNIQUE KEY `UK_BBF_DEPARTAMENTOS_CODIGO` (`CODIGO_DANE`),
  KEY `IDX_BBF_DEPARTAMENTOS_NOMBRE` (`NOMBRE`),
  KEY `IDX_BBF_DEPARTAMENTOS_ACTIVO` (`ACTIVO`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_departamentos`
--

LOCK TABLES `bbf_departamentos` WRITE;
/*!40000 ALTER TABLE `bbf_departamentos` DISABLE KEYS */;
INSERT INTO `bbf_departamentos` VALUES (1,'05','Antioquia',1,'2026-07-23 20:46:21',NULL),(2,'08','Atlántico',1,'2026-07-23 20:46:21',NULL),(3,'11','Bogotá D.C.',1,'2026-07-23 20:46:21',NULL),(4,'13','Bolívar',1,'2026-07-23 20:46:21',NULL),(5,'15','Boyacá',1,'2026-07-23 20:46:21',NULL),(6,'17','Caldas',1,'2026-07-23 20:46:21',NULL),(7,'18','Caquetá',1,'2026-07-23 20:46:21',NULL),(8,'19','Cauca',1,'2026-07-23 20:46:21',NULL),(9,'20','Cesar',1,'2026-07-23 20:46:21',NULL),(10,'23','Córdoba',1,'2026-07-23 20:46:21',NULL),(11,'25','Cundinamarca',1,'2026-07-23 20:46:21',NULL),(12,'27','Chocó',1,'2026-07-23 20:46:21',NULL),(13,'41','Huila',1,'2026-07-23 20:46:21',NULL),(14,'44','La Guajira',1,'2026-07-23 20:46:21',NULL),(15,'47','Magdalena',1,'2026-07-23 20:46:21',NULL),(16,'50','Meta',1,'2026-07-23 20:46:21',NULL),(17,'52','Nariño',1,'2026-07-23 20:46:21',NULL),(18,'54','Norte de Santander',1,'2026-07-23 20:46:21',NULL),(19,'63','Quindío',1,'2026-07-23 20:46:21',NULL),(20,'66','Risaralda',1,'2026-07-23 20:46:21',NULL),(21,'68','Santander',1,'2026-07-23 20:46:21',NULL),(22,'70','Sucre',1,'2026-07-23 20:46:21',NULL),(23,'73','Tolima',1,'2026-07-23 20:46:21',NULL),(24,'76','Valle del Cauca',1,'2026-07-23 20:46:21',NULL),(25,'81','Arauca',1,'2026-07-23 20:46:21',NULL),(26,'85','Casanare',1,'2026-07-23 20:46:21',NULL),(27,'86','Putumayo',1,'2026-07-23 20:46:21',NULL),(28,'88','Archipiélago de San Andrés, Providencia y Santa Catalina',1,'2026-07-23 20:46:21',NULL),(29,'91','Amazonas',1,'2026-07-23 20:46:21',NULL),(30,'94','Guainía',1,'2026-07-23 20:46:21',NULL),(31,'95','Guaviare',1,'2026-07-23 20:46:21',NULL),(32,'97','Vaupés',1,'2026-07-23 20:46:21',NULL),(33,'99','Vichada',1,'2026-07-23 20:46:21',NULL),(34,'00','Extranjero',1,'2026-07-24 06:52:27',NULL);
/*!40000 ALTER TABLE `bbf_departamentos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_devolucion_detalle`
--

DROP TABLE IF EXISTS `bbf_devolucion_detalle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_devolucion_detalle` (
  `ID_DEVOLUCION_DETALLE` int(11) NOT NULL AUTO_INCREMENT,
  `ID_DEVOLUCION` int(11) NOT NULL,
  `ID_DOTACION_ENTREGA_DETALLE` int(11) DEFAULT NULL,
  `ID_HERRAMIENTA_ENTREGA_DETALLE` int(11) DEFAULT NULL,
  `CANTIDAD_DEVUELTA` int(11) NOT NULL,
  `ESTADO_ELEMENTO` enum('BUENO','USADO','DETERIORADO','DANADO','INCOMPLETO','NO_FUNCIONAL') NOT NULL,
  `OBSERVACIONES` varchar(500) DEFAULT NULL,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_DEVOLUCION_DETALLE`),
  UNIQUE KEY `UQ_BBF_DEV_DET_DOTACION` (`ID_DEVOLUCION`,`ID_DOTACION_ENTREGA_DETALLE`),
  UNIQUE KEY `UQ_BBF_DEV_DET_HERRAMIENTA` (`ID_DEVOLUCION`,`ID_HERRAMIENTA_ENTREGA_DETALLE`),
  KEY `IDX_BBF_DEV_DET_DOTACION` (`ID_DOTACION_ENTREGA_DETALLE`),
  KEY `IDX_BBF_DEV_DET_HERRAMIENTA` (`ID_HERRAMIENTA_ENTREGA_DETALLE`),
  CONSTRAINT `FK_BBF_DEV_DET_DEVOLUCION` FOREIGN KEY (`ID_DEVOLUCION`) REFERENCES `bbf_devoluciones` (`ID_DEVOLUCION`),
  CONSTRAINT `FK_BBF_DEV_DET_DOTACION` FOREIGN KEY (`ID_DOTACION_ENTREGA_DETALLE`) REFERENCES `bbf_dotacion_entrega_detalle` (`ID_DOTACION_ENTREGA_DETALLE`),
  CONSTRAINT `FK_BBF_DEV_DET_HERRAMIENTA` FOREIGN KEY (`ID_HERRAMIENTA_ENTREGA_DETALLE`) REFERENCES `bbf_herramientas_entrega_detalle` (`id_detalle`),
  CONSTRAINT `CHK_BBF_DEV_DET_ORIGEN` CHECK (`ID_DOTACION_ENTREGA_DETALLE` is not null and `ID_HERRAMIENTA_ENTREGA_DETALLE` is null or `ID_DOTACION_ENTREGA_DETALLE` is null and `ID_HERRAMIENTA_ENTREGA_DETALLE` is not null),
  CONSTRAINT `CHK_BBF_DEV_DET_CANTIDAD` CHECK (`CANTIDAD_DEVUELTA` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_devolucion_detalle`
--

LOCK TABLES `bbf_devolucion_detalle` WRITE;
/*!40000 ALTER TABLE `bbf_devolucion_detalle` DISABLE KEYS */;
/*!40000 ALTER TABLE `bbf_devolucion_detalle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_devolucion_evidencias`
--

DROP TABLE IF EXISTS `bbf_devolucion_evidencias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_devolucion_evidencias` (
  `ID_DEVOLUCION_EVIDENCIA` int(11) NOT NULL AUTO_INCREMENT,
  `ID_DEVOLUCION` int(11) NOT NULL,
  `TIPO_EVIDENCIA` enum('FOTO','DOCUMENTO','OTRO') NOT NULL,
  `NOMBRE_ARCHIVO` varchar(255) NOT NULL,
  `NOMBRE_ORIGINAL` varchar(255) DEFAULT NULL,
  `ARCHIVO_URL` varchar(500) DEFAULT NULL,
  `ARCHIVO_RUTA` varchar(500) DEFAULT NULL,
  `MIME_TYPE` varchar(100) NOT NULL,
  `PESO_BYTES` bigint(20) DEFAULT NULL,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`ID_DEVOLUCION_EVIDENCIA`),
  KEY `IDX_BBF_DEV_EVIDENCIAS_DEVOLUCION` (`ID_DEVOLUCION`),
  CONSTRAINT `FK_BBF_DEV_EVIDENCIAS_DEVOLUCION` FOREIGN KEY (`ID_DEVOLUCION`) REFERENCES `bbf_devoluciones` (`ID_DEVOLUCION`),
  CONSTRAINT `CHK_BBF_DEV_EVIDENCIA_UBICACION` CHECK (`ARCHIVO_URL` is not null and trim(`ARCHIVO_URL`) <> '' and (`ARCHIVO_RUTA` is null or trim(`ARCHIVO_RUTA`) = '') or `ARCHIVO_RUTA` is not null and trim(`ARCHIVO_RUTA`) <> '' and (`ARCHIVO_URL` is null or trim(`ARCHIVO_URL`) = '')),
  CONSTRAINT `CHK_BBF_DEV_EVIDENCIA_PESO` CHECK (`PESO_BYTES` is null or `PESO_BYTES` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_devolucion_evidencias`
--

LOCK TABLES `bbf_devolucion_evidencias` WRITE;
/*!40000 ALTER TABLE `bbf_devolucion_evidencias` DISABLE KEYS */;
/*!40000 ALTER TABLE `bbf_devolucion_evidencias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_devoluciones`
--

DROP TABLE IF EXISTS `bbf_devoluciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_devoluciones` (
  `ID_DEVOLUCION` int(11) NOT NULL AUTO_INCREMENT,
  `TIPO_DEVOLUCION` enum('DOTACION','HERRAMIENTA') NOT NULL,
  `ID_EMPLEADO` int(11) NOT NULL,
  `ID_DOTACION_ENTREGA` int(11) DEFAULT NULL,
  `ID_HERRAMIENTA_ENTREGA` int(11) DEFAULT NULL,
  `FECHA_DEVOLUCION` date NOT NULL,
  `ESTADO` enum('REGISTRADA','CONFIRMADA','ANULADA') NOT NULL DEFAULT 'REGISTRADA',
  `MOTIVO` varchar(500) NOT NULL,
  `OBSERVACIONES` text DEFAULT NULL,
  `ID_REGISTRADO_POR` int(11) NOT NULL,
  `ID_CONFIRMADO_POR` int(11) DEFAULT NULL,
  `FECHA_CONFIRMACION` datetime DEFAULT NULL,
  `ID_ANULADO_POR` int(11) DEFAULT NULL,
  `FECHA_ANULACION` datetime DEFAULT NULL,
  `MOTIVO_ANULACION` varchar(500) DEFAULT NULL,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_DEVOLUCION`),
  KEY `IDX_BBF_DEVOLUCIONES_EMPLEADO` (`ID_EMPLEADO`,`TIPO_DEVOLUCION`,`ESTADO`),
  KEY `IDX_BBF_DEVOLUCIONES_DOTACION` (`ID_DOTACION_ENTREGA`),
  KEY `IDX_BBF_DEVOLUCIONES_HERRAMIENTA` (`ID_HERRAMIENTA_ENTREGA`),
  KEY `IDX_BBF_DEVOLUCIONES_FECHA` (`FECHA_DEVOLUCION`),
  KEY `FK_BBF_DEVOLUCIONES_REGISTRADO_POR` (`ID_REGISTRADO_POR`),
  KEY `FK_BBF_DEVOLUCIONES_CONFIRMADO_POR` (`ID_CONFIRMADO_POR`),
  KEY `FK_BBF_DEVOLUCIONES_ANULADO_POR` (`ID_ANULADO_POR`),
  CONSTRAINT `FK_BBF_DEVOLUCIONES_ANULADO_POR` FOREIGN KEY (`ID_ANULADO_POR`) REFERENCES `bbf_usuarios` (`ID_USUARIO`),
  CONSTRAINT `FK_BBF_DEVOLUCIONES_CONFIRMADO_POR` FOREIGN KEY (`ID_CONFIRMADO_POR`) REFERENCES `bbf_usuarios` (`ID_USUARIO`),
  CONSTRAINT `FK_BBF_DEVOLUCIONES_DOTACION_ENTREGA` FOREIGN KEY (`ID_DOTACION_ENTREGA`) REFERENCES `bbf_dotacion_entregas` (`ID_DOTACION_ENTREGA`),
  CONSTRAINT `FK_BBF_DEVOLUCIONES_EMPLEADO` FOREIGN KEY (`ID_EMPLEADO`) REFERENCES `bbf_empleados` (`ID_EMPLEADO`),
  CONSTRAINT `FK_BBF_DEVOLUCIONES_HERRAMIENTA_ENTREGA` FOREIGN KEY (`ID_HERRAMIENTA_ENTREGA`) REFERENCES `bbf_herramientas_entregas` (`id_entrega`),
  CONSTRAINT `FK_BBF_DEVOLUCIONES_REGISTRADO_POR` FOREIGN KEY (`ID_REGISTRADO_POR`) REFERENCES `bbf_usuarios` (`ID_USUARIO`),
  CONSTRAINT `CHK_BBF_DEVOLUCIONES_ORIGEN` CHECK (`TIPO_DEVOLUCION` = 'DOTACION' and `ID_DOTACION_ENTREGA` is not null and `ID_HERRAMIENTA_ENTREGA` is null or `TIPO_DEVOLUCION` = 'HERRAMIENTA' and `ID_HERRAMIENTA_ENTREGA` is not null and `ID_DOTACION_ENTREGA` is null)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_devoluciones`
--

LOCK TABLES `bbf_devoluciones` WRITE;
/*!40000 ALTER TABLE `bbf_devoluciones` DISABLE KEYS */;
/*!40000 ALTER TABLE `bbf_devoluciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_dominios_autorizados`
--

DROP TABLE IF EXISTS `bbf_dominios_autorizados`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_dominios_autorizados` (
  `ID_DOMINIO` int(11) NOT NULL AUTO_INCREMENT,
  `DOMINIO` varchar(150) NOT NULL,
  `DESCRIPCION` varchar(250) DEFAULT NULL,
  `ACTIVO` tinyint(1) NOT NULL DEFAULT 1,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_DOMINIO`),
  UNIQUE KEY `UQ_BBF_DOMINIOS_AUTORIZADOS_DOMINIO` (`DOMINIO`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_dominios_autorizados`
--

LOCK TABLES `bbf_dominios_autorizados` WRITE;
/*!40000 ALTER TABLE `bbf_dominios_autorizados` DISABLE KEYS */;
INSERT INTO `bbf_dominios_autorizados` VALUES (1,'barroblancofarms.com.co','Dominio corporativo Barro Blanco Farms',1,'2026-06-22 19:25:13','2026-06-22 19:25:13');
/*!40000 ALTER TABLE `bbf_dominios_autorizados` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_dotacion_articulo_alias_cargue`
--

DROP TABLE IF EXISTS `bbf_dotacion_articulo_alias_cargue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_dotacion_articulo_alias_cargue` (
  `ID_DOTACION_ARTICULO_ALIAS` int(11) NOT NULL AUTO_INCREMENT,
  `ID_DOTACION_ARTICULO` int(11) NOT NULL,
  `ENCABEZADO_XLSX` varchar(200) NOT NULL,
  `ACTIVO` tinyint(1) NOT NULL DEFAULT 1,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_DOTACION_ARTICULO_ALIAS`),
  UNIQUE KEY `UQ_BBF_DOT_ART_ALIAS_ENCABEZADO` (`ENCABEZADO_XLSX`),
  KEY `IDX_BBF_DOT_ART_ALIAS_ARTICULO` (`ID_DOTACION_ARTICULO`,`ACTIVO`),
  CONSTRAINT `FK_BBF_DOT_ART_ALIAS_ARTICULO` FOREIGN KEY (`ID_DOTACION_ARTICULO`) REFERENCES `bbf_dotacion_articulos` (`ID_DOTACION_ARTICULO`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_dotacion_articulo_alias_cargue`
--

LOCK TABLES `bbf_dotacion_articulo_alias_cargue` WRITE;
/*!40000 ALTER TABLE `bbf_dotacion_articulo_alias_cargue` DISABLE KEYS */;
INSERT INTO `bbf_dotacion_articulo_alias_cargue` VALUES (1,16,'Bata Hombre Tipo Labo Dril Bor BARRO B',1,'2026-08-10 10:19:40',NULL),(2,16,'Bata Mujer Tipo Labo Dril Bor BARRO B',1,'2026-08-10 10:19:40',NULL),(3,17,'BOTA CUERO LISO SP',1,'2026-08-10 10:19:40',NULL),(4,18,'Bota Cuero Micropiel RH-PP-DE',1,'2026-08-10 10:19:40',NULL),(5,19,'BOTA PVC MACHA ALTA',1,'2026-08-10 10:19:40',NULL),(6,20,'BOTA PVC MACHITA',1,'2026-08-10 10:19:40',NULL),(7,45,'CAMISA JEAN  BORDADO BB',1,'2026-08-10 10:19:40',NULL),(8,44,'CAMISA MANGA LARGA  BORDADO BB',1,'2026-08-10 10:19:40',NULL),(9,25,'CCamiseta Tipo Polo  Bor Barro B',1,'2026-08-10 10:19:40',NULL),(10,32,'Overol 1P  Estampado  BARRO B',1,'2026-08-10 10:19:40',NULL),(11,33,'Overol 1P C/Refle Estampado Brig BARRO B',1,'2026-08-10 10:19:40',NULL),(12,30,'Overol dos piezas Estampad Hombr BARRO',1,'2026-08-10 10:19:40',NULL),(13,31,'Overol dos piezas Estampad Mujer BARRO B',1,'2026-08-10 10:19:40',NULL),(14,35,'Overol Tipo Tyvek Coltejer BARRO B',1,'2026-08-10 10:19:40',NULL),(15,43,'PANTALON  JEAN estampado Barro B',1,'2026-08-10 10:19:40',NULL),(16,36,'Pantalon Dril Hombre Estampado Barro B',1,'2026-08-10 10:19:40',NULL),(17,39,'Pantalon Dril Mujer Estampado Barro B',1,'2026-08-10 10:19:40',NULL),(18,29,'TRAJE DE CUARTO FRIO',1,'2026-08-10 10:19:40',NULL),(19,42,'UNIFORME 2 P S. GENERAL BLUSA PANTALON',1,'2026-08-10 10:19:40',NULL),(20,46,'Zueco',1,'2026-08-10 10:19:40',NULL);
/*!40000 ALTER TABLE `bbf_dotacion_articulo_alias_cargue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_dotacion_articulos`
--

DROP TABLE IF EXISTS `bbf_dotacion_articulos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_dotacion_articulos` (
  `ID_DOTACION_ARTICULO` int(11) NOT NULL AUTO_INCREMENT,
  `CODIGO` varchar(50) NOT NULL,
  `ID_TIPO_DOTACION` int(11) NOT NULL,
  `NOMBRE` varchar(200) NOT NULL,
  `DESCRIPCION` varchar(500) DEFAULT NULL,
  `GENERO` enum('HOMBRE','MUJER','UNISEX','NO_APLICA') NOT NULL DEFAULT 'UNISEX',
  `UNIDAD_MEDIDA` enum('UNIDAD','PAR','JUEGO') NOT NULL DEFAULT 'UNIDAD',
  `ES_LEGACY` tinyint(1) NOT NULL DEFAULT 0,
  `ACTIVO` tinyint(1) NOT NULL DEFAULT 1,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_DOTACION_ARTICULO`),
  UNIQUE KEY `UQ_BBF_DOT_ARTICULOS_CODIGO` (`CODIGO`),
  UNIQUE KEY `UQ_BBF_DOT_ARTICULOS_NOMBRE` (`NOMBRE`),
  UNIQUE KEY `UQ_BBF_DOT_ARTICULO_TIPO` (`ID_DOTACION_ARTICULO`,`ID_TIPO_DOTACION`),
  KEY `IDX_BBF_DOT_ARTICULOS_TIPO` (`ID_TIPO_DOTACION`),
  KEY `IDX_BBF_DOT_ARTICULOS_ACTIVO` (`ACTIVO`,`ID_TIPO_DOTACION`),
  CONSTRAINT `FK_BBF_DOT_ARTICULOS_TIPO` FOREIGN KEY (`ID_TIPO_DOTACION`) REFERENCES `bbf_tipos_dotacion` (`ID_TIPO_DOTACION`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_dotacion_articulos`
--

LOCK TABLES `bbf_dotacion_articulos` WRITE;
/*!40000 ALTER TABLE `bbf_dotacion_articulos` DISABLE KEYS */;
INSERT INTO `bbf_dotacion_articulos` VALUES (1,'LEGACY_TIPO_010',10,'Bata','Artículo histórico migrado desde el tipo genérico: Bata.','UNISEX','UNIDAD',1,0,'2026-08-03 12:00:55',NULL),(2,'LEGACY_TIPO_003',3,'Calzado','Artículo histórico migrado desde el tipo genérico: Calzado.','UNISEX','PAR',1,0,'2026-08-03 12:00:55',NULL),(3,'LEGACY_TIPO_001',1,'Camisa','Artículo histórico migrado desde el tipo genérico: Camisa.','UNISEX','UNIDAD',1,0,'2026-08-03 12:00:55',NULL),(4,'LEGACY_TIPO_007',7,'Chaqueta','Artículo histórico migrado desde el tipo genérico: Chaqueta.','UNISEX','UNIDAD',1,0,'2026-08-03 12:00:55',NULL),(5,'LEGACY_TIPO_006',6,'Delantal','Artículo histórico migrado desde el tipo genérico: Delantal.','UNISEX','UNIDAD',1,0,'2026-08-03 12:00:55',NULL),(6,'LEGACY_TIPO_005',5,'Gorra','Artículo histórico migrado desde el tipo genérico: Gorra.','UNISEX','UNIDAD',1,0,'2026-08-03 12:00:55',NULL),(7,'LEGACY_TIPO_004',4,'Guantes','Artículo histórico migrado desde el tipo genérico: Guantes.','UNISEX','UNIDAD',1,0,'2026-08-03 12:00:55',NULL),(8,'LEGACY_TIPO_009',9,'Overol','Artículo histórico migrado desde el tipo genérico: Overol.','UNISEX','UNIDAD',1,0,'2026-08-03 12:00:55',NULL),(9,'LEGACY_TIPO_002',2,'Pantalón','Artículo histórico migrado desde el tipo genérico: Pantalón.','UNISEX','UNIDAD',1,0,'2026-08-03 12:00:55',NULL),(16,'BATA_DRILL',10,'Bata tipo Drill','Bata elaborada en material tipo Drill.','UNISEX','UNIDAD',0,1,'2026-08-03 12:00:55',NULL),(17,'BOTA_CUERO_LISO',3,'Bota cuero Liso','Bota elaborada en cuero liso.','UNISEX','PAR',0,1,'2026-08-03 12:00:55',NULL),(18,'BOTA_CUERO_MICROPIEL',3,'Bota Cuero micropiel','Bota de cuero tipo micropiel.','UNISEX','PAR',0,1,'2026-08-03 12:00:55',NULL),(19,'BOTA_PVC_MACHA_ALTA',3,'Bota PVC macha alta','Bota en PVC denominada macha alta.','UNISEX','PAR',0,1,'2026-08-03 12:00:55',NULL),(20,'BOTA_PVC_MACHITA',3,'Bota PVC machita','Bota en PVC denominada machita.','UNISEX','PAR',0,1,'2026-08-03 12:00:55',NULL),(21,'BUSO_CAPOTA_PERCHADO',7,'Buso capota perchado','Buso perchado con capota.','UNISEX','UNIDAD',0,1,'2026-08-03 12:00:55',NULL),(22,'CAMISA_ADMON',1,'Camisa Admon','Camisa para personal administrativo.','UNISEX','UNIDAD',0,1,'2026-08-03 12:00:55',NULL),(23,'CAMISA_OVEROL_HOMBRE',1,'Camisa Overol Hombre','Camisa para overol de hombre.','HOMBRE','UNIDAD',0,1,'2026-08-03 12:00:55',NULL),(24,'CAMISA_OVEROL_MUJER',1,'Camisa Overol Mujer','Camisa para overol de mujer.','MUJER','UNIDAD',0,1,'2026-08-03 12:00:55',NULL),(25,'CAMISETA_POLO_HOMBRE',1,'Camiseta tipo Polo Hombre','Camiseta tipo polo para hombre.','UNISEX','UNIDAD',0,1,'2026-08-03 12:00:55','2026-08-10 10:19:40'),(26,'CASCO_BARBUQUEJO',11,'Casco seguridad con barbuquejo','Casco de seguridad con barbuquejo.','UNISEX','UNIDAD',0,1,'2026-08-03 12:00:55',NULL),(27,'CHALECO_BORDADO',7,'Chaleco bordado','Chaleco institucional bordado.','UNISEX','UNIDAD',0,1,'2026-08-03 12:00:55',NULL),(28,'CHANCLAS',3,'CHANCLAS','Chanclas entregadas como parte de la dotación.','UNISEX','PAR',0,1,'2026-08-03 12:00:55',NULL),(29,'CHAQUETA_CUARTO_FRIO',7,'Chaqueta Cuarto Frio','Chaqueta para trabajo en cuarto frío.','UNISEX','UNIDAD',0,1,'2026-08-03 12:00:55',NULL),(30,'OVEROL_2P_HOMBRE',9,'Overol 2 piezas HOMBRE','Overol de dos piezas para hombre.','HOMBRE','JUEGO',0,1,'2026-08-03 12:00:55',NULL),(31,'OVEROL_2P_MUJER',9,'Overol 2 piezas MUJER','Overol de dos piezas para mujer.','MUJER','JUEGO',0,1,'2026-08-03 12:00:55',NULL),(32,'OVEROL_EST_ENTERIZO',9,'Overol Estampado Enterizo','Overol estampado enterizo.','UNISEX','UNIDAD',0,1,'2026-08-03 12:00:55',NULL),(33,'OVEROL_EST_REFLECTIVO',9,'Overol Estampado Enterizo Reflectivo','Overol estampado enterizo con elementos reflectivos.','UNISEX','UNIDAD',0,1,'2026-08-03 12:00:55',NULL),(34,'OVEROL_FUMIGACION',9,'Overol reforzado Fumigación','Overol reforzado para labores de fumigación.','UNISEX','UNIDAD',0,1,'2026-08-03 12:00:55',NULL),(35,'OVEROL_TYVEK',9,'Overol tipo Tyvek','Overol elaborado en material tipo Tyvek.','UNISEX','UNIDAD',0,1,'2026-08-03 12:00:55',NULL),(36,'PANT_DRIL_HOMBRE',2,'Pantalón Dril HOMBRE','Pantalón en material Dril para hombre.','HOMBRE','UNIDAD',0,1,'2026-08-03 12:00:55',NULL),(37,'PANT_HOMBRE_CLASICO',2,'Pantalón Hombre clásico','Pantalón clásico para hombre.','HOMBRE','UNIDAD',0,1,'2026-08-03 12:00:55',NULL),(38,'PANT_JEAN_DAMA_LICRADO',2,'Pantalón jean dama licrado','Pantalón jean licrado para mujer.','MUJER','UNIDAD',0,1,'2026-08-03 12:00:55',NULL),(39,'PANT_MUJER_DRILL',2,'Pantalón Mujer Drill','Pantalón en material Drill para mujer.','MUJER','UNIDAD',0,1,'2026-08-03 12:00:55',NULL),(40,'PETO_PELADORES',11,'Peto peladores','Peto utilizado por el personal de pelado.','UNISEX','UNIDAD',0,1,'2026-08-03 12:00:55',NULL),(41,'TOALLA_CUERPO',11,'TOALLA DE CUERPO','Toalla de cuerpo.','NO_APLICA','UNIDAD',0,1,'2026-08-03 12:00:55',NULL),(42,'UNIFORME_2P_SERV_GENERALES',9,'Uniforme 2 piezas servicios generales','Uniforme de blusa y pantalón para servicios generales.','MUJER','JUEGO',0,1,'2026-08-10 10:19:40',NULL),(43,'PANT_JEAN_ESTAMPADO',2,'Pantalón jean estampado','Pantalón jean institucional estampado para hombre o mujer.','UNISEX','UNIDAD',0,1,'2026-08-10 10:19:40',NULL),(44,'CAMISA_MANGA_LARGA_BORDADA',1,'Camisa manga larga bordada','Camisa institucional de manga larga bordada.','UNISEX','UNIDAD',0,1,'2026-08-10 10:19:40',NULL),(45,'CAMISA_JEAN_BORDADA',1,'Camisa jean bordada','Camisa jean institucional bordada.','UNISEX','UNIDAD',0,1,'2026-08-10 10:19:40',NULL),(46,'ZUECO',3,'Zueco','Zueco utilizado como calzado de dotación.','UNISEX','PAR',0,1,'2026-08-10 10:19:40',NULL);
/*!40000 ALTER TABLE `bbf_dotacion_articulos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_dotacion_combinacion_detalle`
--

DROP TABLE IF EXISTS `bbf_dotacion_combinacion_detalle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_dotacion_combinacion_detalle` (
  `ID_DOTACION_COMBINACION_DETALLE` int(11) NOT NULL AUTO_INCREMENT,
  `ID_DOTACION_COMBINACION` int(11) NOT NULL,
  `ID_TIPO_DOTACION` int(11) NOT NULL,
  `CANTIDAD` int(11) NOT NULL DEFAULT 1,
  `ORDEN` int(11) NOT NULL DEFAULT 0,
  `ACTIVO` tinyint(1) NOT NULL DEFAULT 1,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_DOTACION_COMBINACION_DETALLE`),
  UNIQUE KEY `UQ_BBF_DOT_COMB_TIPO` (`ID_DOTACION_COMBINACION`,`ID_TIPO_DOTACION`),
  KEY `IDX_BBF_DOT_COMB_DET_COMBINACION` (`ID_DOTACION_COMBINACION`),
  KEY `IDX_BBF_DOT_COMB_DET_TIPO` (`ID_TIPO_DOTACION`),
  CONSTRAINT `FK_BBF_DOT_COMB_DET_COMBINACION` FOREIGN KEY (`ID_DOTACION_COMBINACION`) REFERENCES `bbf_dotacion_combinaciones` (`ID_DOTACION_COMBINACION`),
  CONSTRAINT `FK_BBF_DOT_COMB_DET_TIPO` FOREIGN KEY (`ID_TIPO_DOTACION`) REFERENCES `bbf_tipos_dotacion` (`ID_TIPO_DOTACION`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_dotacion_combinacion_detalle`
--

LOCK TABLES `bbf_dotacion_combinacion_detalle` WRITE;
/*!40000 ALTER TABLE `bbf_dotacion_combinacion_detalle` DISABLE KEYS */;
INSERT INTO `bbf_dotacion_combinacion_detalle` VALUES (1,1,7,1,1,1,'2026-07-24 09:36:22',NULL),(2,1,2,1,2,1,'2026-07-24 09:36:22',NULL),(3,1,3,1,3,1,'2026-07-24 09:36:23',NULL),(4,2,10,1,1,1,'2026-07-24 09:36:23',NULL),(5,2,3,1,2,1,'2026-07-24 09:36:23',NULL),(6,3,7,1,1,1,'2026-07-24 09:36:23',NULL),(7,3,1,1,2,1,'2026-07-24 09:36:23',NULL),(8,3,2,1,3,1,'2026-07-24 09:36:23',NULL);
/*!40000 ALTER TABLE `bbf_dotacion_combinacion_detalle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_dotacion_combinaciones`
--

DROP TABLE IF EXISTS `bbf_dotacion_combinaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_dotacion_combinaciones` (
  `ID_DOTACION_COMBINACION` int(11) NOT NULL AUTO_INCREMENT,
  `CODIGO` varchar(30) NOT NULL,
  `NOMBRE` varchar(200) NOT NULL,
  `DESCRIPCION` varchar(500) DEFAULT NULL,
  `ACTIVO` tinyint(1) NOT NULL DEFAULT 1,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_DOTACION_COMBINACION`),
  UNIQUE KEY `UQ_BBF_DOTACION_COMBINACION_CODIGO` (`CODIGO`),
  UNIQUE KEY `UQ_BBF_DOTACION_COMBINACION_NOMBRE` (`NOMBRE`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_dotacion_combinaciones`
--

LOCK TABLES `bbf_dotacion_combinaciones` WRITE;
/*!40000 ALTER TABLE `bbf_dotacion_combinaciones` DISABLE KEYS */;
INSERT INTO `bbf_dotacion_combinaciones` VALUES (1,'DOT-01','Chaqueta, pantalón y zapatos','Dotación compuesta por chaqueta, pantalón y calzado.',1,'2026-07-24 09:36:22',NULL),(2,'DOT-02','Bata y zapatos','Dotación compuesta por bata y calzado.',1,'2026-07-24 09:36:22',NULL),(3,'DOT-03','Chaqueta, camisa y pantalón','Dotación compuesta por chaqueta, camisa y pantalón.',1,'2026-07-24 09:36:22',NULL);
/*!40000 ALTER TABLE `bbf_dotacion_combinaciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_dotacion_entrega_detalle`
--

DROP TABLE IF EXISTS `bbf_dotacion_entrega_detalle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_dotacion_entrega_detalle` (
  `ID_DOTACION_ENTREGA_DETALLE` int(11) NOT NULL AUTO_INCREMENT,
  `ID_DOTACION_ENTREGA` int(11) NOT NULL,
  `ID_TIPO_DOTACION` int(11) NOT NULL,
  `ID_DOTACION_ARTICULO` int(11) DEFAULT NULL,
  `ID_TALLA_DOTACION` int(11) DEFAULT NULL,
  `CANTIDAD` int(11) NOT NULL DEFAULT 1,
  `OBSERVACIONES` varchar(250) DEFAULT NULL,
  `ELIMINADO` tinyint(1) NOT NULL DEFAULT 0,
  `FECHA_ELIMINACION` datetime DEFAULT NULL,
  `ID_ELIMINADO_POR` int(11) DEFAULT NULL,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`ID_DOTACION_ENTREGA_DETALLE`),
  KEY `FK_BBF_DOT_DET_ENTREGA` (`ID_DOTACION_ENTREGA`),
  KEY `FK_BBF_DOT_DET_TIPO` (`ID_TIPO_DOTACION`),
  KEY `FK_BBF_DOT_DET_TALLA` (`ID_TALLA_DOTACION`),
  KEY `FK_BBF_DOT_DET_ELIMINADO_POR` (`ID_ELIMINADO_POR`),
  KEY `IDX_BBF_DOT_DET_ARTICULO_TIPO` (`ID_DOTACION_ARTICULO`,`ID_TIPO_DOTACION`),
  CONSTRAINT `FK_BBF_DOT_DET_ARTICULO_TIPO` FOREIGN KEY (`ID_DOTACION_ARTICULO`, `ID_TIPO_DOTACION`) REFERENCES `bbf_dotacion_articulos` (`ID_DOTACION_ARTICULO`, `ID_TIPO_DOTACION`),
  CONSTRAINT `FK_BBF_DOT_DET_ELIMINADO_POR` FOREIGN KEY (`ID_ELIMINADO_POR`) REFERENCES `bbf_usuarios` (`ID_USUARIO`),
  CONSTRAINT `FK_BBF_DOT_DET_ENTREGA` FOREIGN KEY (`ID_DOTACION_ENTREGA`) REFERENCES `bbf_dotacion_entregas` (`ID_DOTACION_ENTREGA`) ON DELETE CASCADE,
  CONSTRAINT `FK_BBF_DOT_DET_TALLA` FOREIGN KEY (`ID_TALLA_DOTACION`) REFERENCES `bbf_tallas_dotacion` (`ID_TALLA_DOTACION`),
  CONSTRAINT `FK_BBF_DOT_DET_TIPO` FOREIGN KEY (`ID_TIPO_DOTACION`) REFERENCES `bbf_tipos_dotacion` (`ID_TIPO_DOTACION`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_dotacion_entrega_detalle`
--

LOCK TABLES `bbf_dotacion_entrega_detalle` WRITE;
/*!40000 ALTER TABLE `bbf_dotacion_entrega_detalle` DISABLE KEYS */;
/*!40000 ALTER TABLE `bbf_dotacion_entrega_detalle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_dotacion_entregas`
--

DROP TABLE IF EXISTS `bbf_dotacion_entregas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_dotacion_entregas` (
  `ID_DOTACION_ENTREGA` int(11) NOT NULL AUTO_INCREMENT,
  `ID_EMPLEADO` int(11) NOT NULL,
  `FECHA_ENTREGA` date NOT NULL,
  `TIPO_ENTREGA` enum('ORDINARIA','EXTRAORDINARIA') NOT NULL DEFAULT 'ORDINARIA',
  `ID_DOTACION_COMBINACION` int(11) DEFAULT NULL,
  `FECHA_CONFIRMACION` datetime DEFAULT NULL,
  `ESTADO` enum('POR_COMPRAR','REGISTRADA','ENTREGADA','ANULADA') NOT NULL DEFAULT 'REGISTRADA',
  `ELIMINADO` tinyint(1) NOT NULL DEFAULT 0,
  `FECHA_ELIMINACION` datetime DEFAULT NULL,
  `ID_ELIMINADO_POR` int(11) DEFAULT NULL,
  `MOTIVO_ELIMINACION` varchar(500) DEFAULT NULL,
  `OBSERVACIONES` text DEFAULT NULL,
  `OBSERVACION_CONFIRMACION` varchar(500) DEFAULT NULL,
  `FIRMA_URL` varchar(500) DEFAULT NULL,
  `EVIDENCIA_NOMBRE_ARCHIVO` varchar(255) DEFAULT NULL,
  `EVIDENCIA_NOMBRE_ORIGINAL` varchar(255) DEFAULT NULL,
  `EVIDENCIA_URL` varchar(500) DEFAULT NULL,
  `EVIDENCIA_RUTA` varchar(500) DEFAULT NULL,
  `EVIDENCIA_MIME_TYPE` varchar(100) DEFAULT NULL,
  `EVIDENCIA_PESO_BYTES` bigint(20) DEFAULT NULL,
  `EVIDENCIA_FECHA_CARGA` datetime DEFAULT NULL,
  `ID_REGISTRADO_POR` int(11) DEFAULT NULL,
  `ID_CONFIRMADO_POR` int(11) DEFAULT NULL,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_DOTACION_ENTREGA`),
  KEY `FK_BBF_DOT_ENTREGAS_EMPLEADO` (`ID_EMPLEADO`),
  KEY `FK_BBF_DOT_ENTREGAS_USUARIO` (`ID_REGISTRADO_POR`),
  KEY `FK_BBF_DOT_ENTREGAS_CONFIRMADO_POR` (`ID_CONFIRMADO_POR`),
  KEY `FK_BBF_DOT_ENTREGAS_ELIMINADO_POR` (`ID_ELIMINADO_POR`),
  KEY `FK_BBF_DOT_ENTREGA_COMBINACION` (`ID_DOTACION_COMBINACION`),
  KEY `IX_BBF_DOTACION_ENTREGAS_ESTADO` (`ESTADO`,`ELIMINADO`,`FECHA_ENTREGA`),
  CONSTRAINT `FK_BBF_DOT_ENTREGAS_CONFIRMADO_POR` FOREIGN KEY (`ID_CONFIRMADO_POR`) REFERENCES `bbf_usuarios` (`ID_USUARIO`),
  CONSTRAINT `FK_BBF_DOT_ENTREGAS_ELIMINADO_POR` FOREIGN KEY (`ID_ELIMINADO_POR`) REFERENCES `bbf_usuarios` (`ID_USUARIO`),
  CONSTRAINT `FK_BBF_DOT_ENTREGAS_EMPLEADO` FOREIGN KEY (`ID_EMPLEADO`) REFERENCES `bbf_empleados` (`ID_EMPLEADO`),
  CONSTRAINT `FK_BBF_DOT_ENTREGAS_USUARIO` FOREIGN KEY (`ID_REGISTRADO_POR`) REFERENCES `bbf_usuarios` (`ID_USUARIO`),
  CONSTRAINT `FK_BBF_DOT_ENTREGA_COMBINACION` FOREIGN KEY (`ID_DOTACION_COMBINACION`) REFERENCES `bbf_dotacion_combinaciones` (`ID_DOTACION_COMBINACION`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_dotacion_entregas`
--

LOCK TABLES `bbf_dotacion_entregas` WRITE;
/*!40000 ALTER TABLE `bbf_dotacion_entregas` DISABLE KEYS */;
/*!40000 ALTER TABLE `bbf_dotacion_entregas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_empleado_contacto_emergencia`
--

DROP TABLE IF EXISTS `bbf_empleado_contacto_emergencia`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_empleado_contacto_emergencia` (
  `ID_CONTACTO_EMERGENCIA` int(11) NOT NULL AUTO_INCREMENT,
  `ID_EMPLEADO` int(11) NOT NULL,
  `NOMBRE_COMPLETO` varchar(200) NOT NULL,
  `PARENTESCO` varchar(100) DEFAULT NULL,
  `TELEFONO` varchar(50) NOT NULL,
  `TELEFONO_ALTERNO` varchar(50) DEFAULT NULL,
  `DIRECCION` varchar(250) DEFAULT NULL,
  `OBSERVACIONES` varchar(500) DEFAULT NULL,
  `ELIMINADO` tinyint(1) NOT NULL DEFAULT 0,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_CONTACTO_EMERGENCIA`),
  KEY `IDX_BBF_CONTACTO_EMERGENCIA_EMPLEADO` (`ID_EMPLEADO`),
  CONSTRAINT `FK_BBF_CONTACTO_EMERGENCIA_EMPLEADO` FOREIGN KEY (`ID_EMPLEADO`) REFERENCES `bbf_empleados` (`ID_EMPLEADO`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_empleado_contacto_emergencia`
--

LOCK TABLES `bbf_empleado_contacto_emergencia` WRITE;
/*!40000 ALTER TABLE `bbf_empleado_contacto_emergencia` DISABLE KEYS */;
/*!40000 ALTER TABLE `bbf_empleado_contacto_emergencia` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_empleado_contratos`
--

DROP TABLE IF EXISTS `bbf_empleado_contratos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_empleado_contratos` (
  `ID_EMPLEADO_CONTRATO` int(11) NOT NULL AUTO_INCREMENT,
  `ID_EMPLEADO` int(11) NOT NULL,
  `ID_TIPO_CONTRATO` int(11) DEFAULT NULL,
  `ID_PLANTILLA_CONTRATO` int(11) DEFAULT NULL,
  `ID_AREA` int(11) DEFAULT NULL,
  `ID_CARGO` int(11) DEFAULT NULL,
  `FECHA_INICIO` date NOT NULL,
  `FECHA_FIN` date DEFAULT NULL,
  `DURACION_MESES` int(11) DEFAULT NULL,
  `SALARIO_BASE` decimal(12,2) DEFAULT NULL,
  `AUXILIO_TRANSPORTE` tinyint(1) DEFAULT NULL,
  `PERIODO_PAGO` varchar(100) DEFAULT NULL,
  `LUGAR_LABORES` varchar(250) DEFAULT NULL,
  `NUMERO_CONTRATO` varchar(100) DEFAULT NULL,
  `TIPO_CARGO_CONTRATO` enum('ADMINISTRATIVO','OPERATIVO','OTRO') DEFAULT NULL,
  `OBJETO_OBRA_LABOR` text DEFAULT NULL,
  `PRORROGA_DIAS` int(11) DEFAULT NULL,
  `CLAUSULA_FUNCIONES` text DEFAULT NULL,
  `JORNADA_LABORAL` varchar(150) DEFAULT NULL,
  `PERIODO_PRUEBA_DIAS` int(11) DEFAULT NULL,
  `ESTADO_CONTRATO` enum('ACTIVO','VENCIDO','RENOVADO','FINALIZADO','ANULADO') NOT NULL DEFAULT 'ACTIVO',
  `ARCHIVO_CONTRATO_URL` varchar(500) DEFAULT NULL,
  `FECHA_FIRMA` date DEFAULT NULL,
  `OBSERVACIONES` text DEFAULT NULL,
  `ID_REGISTRADO_POR` int(11) DEFAULT NULL,
  `ELIMINADO` tinyint(1) NOT NULL DEFAULT 0,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_EMPLEADO_CONTRATO`),
  KEY `FK_BBF_CONTRATOS_TIPO_CONTRATO` (`ID_TIPO_CONTRATO`),
  KEY `FK_BBF_CONTRATOS_AREA` (`ID_AREA`),
  KEY `FK_BBF_CONTRATOS_CARGO` (`ID_CARGO`),
  KEY `FK_BBF_CONTRATOS_REGISTRADO_POR` (`ID_REGISTRADO_POR`),
  KEY `IDX_BBF_CONTRATOS_EMPLEADO` (`ID_EMPLEADO`),
  KEY `IDX_BBF_CONTRATOS_FECHAS` (`FECHA_INICIO`,`FECHA_FIN`),
  KEY `IDX_BBF_CONTRATOS_ESTADO` (`ESTADO_CONTRATO`),
  KEY `IDX_BBF_EMP_CONTRATO_PLANTILLA` (`ID_PLANTILLA_CONTRATO`),
  CONSTRAINT `FK_BBF_CONTRATOS_AREA` FOREIGN KEY (`ID_AREA`) REFERENCES `bbf_areas` (`ID_AREA`),
  CONSTRAINT `FK_BBF_CONTRATOS_CARGO` FOREIGN KEY (`ID_CARGO`) REFERENCES `bbf_cargos` (`ID_CARGO`),
  CONSTRAINT `FK_BBF_CONTRATOS_EMPLEADO` FOREIGN KEY (`ID_EMPLEADO`) REFERENCES `bbf_empleados` (`ID_EMPLEADO`),
  CONSTRAINT `FK_BBF_CONTRATOS_REGISTRADO_POR` FOREIGN KEY (`ID_REGISTRADO_POR`) REFERENCES `bbf_usuarios` (`ID_USUARIO`),
  CONSTRAINT `FK_BBF_CONTRATOS_TIPO_CONTRATO` FOREIGN KEY (`ID_TIPO_CONTRATO`) REFERENCES `bbf_tipos_contrato` (`ID_TIPO_CONTRATO`),
  CONSTRAINT `FK_BBF_EMP_CONTRATO_PLANTILLA` FOREIGN KEY (`ID_PLANTILLA_CONTRATO`) REFERENCES `bbf_contrato_plantillas` (`ID_PLANTILLA_CONTRATO`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_empleado_contratos`
--

LOCK TABLES `bbf_empleado_contratos` WRITE;
/*!40000 ALTER TABLE `bbf_empleado_contratos` DISABLE KEYS */;
/*!40000 ALTER TABLE `bbf_empleado_contratos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_empleado_documentos`
--

DROP TABLE IF EXISTS `bbf_empleado_documentos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_empleado_documentos` (
  `ID_EMPLEADO_DOCUMENTO` int(11) NOT NULL AUTO_INCREMENT,
  `ID_EMPLEADO` int(11) NOT NULL,
  `ID_EMPLEADO_CONTRATO` int(11) DEFAULT NULL,
  `ID_TIPO_DOCUMENTO_LABORAL` int(11) NOT NULL,
  `NOMBRE_ARCHIVO` varchar(255) NOT NULL,
  `NOMBRE_ORIGINAL` varchar(255) DEFAULT NULL,
  `ARCHIVO_URL` varchar(500) DEFAULT NULL,
  `ARCHIVO_RUTA` varchar(500) DEFAULT NULL,
  `MIME_TYPE` varchar(100) DEFAULT NULL,
  `PESO_BYTES` bigint(20) DEFAULT NULL,
  `FECHA_CARGA` datetime NOT NULL DEFAULT current_timestamp(),
  `FECHA_VENCIMIENTO` date DEFAULT NULL,
  `ESTADO_DOCUMENTO` enum('PENDIENTE','CARGADO','VALIDADO','RECHAZADO','VENCIDO') NOT NULL DEFAULT 'CARGADO',
  `OBSERVACIONES` text DEFAULT NULL,
  `ID_CARGADO_POR` int(11) DEFAULT NULL,
  `ID_VALIDADO_POR` int(11) DEFAULT NULL,
  `FECHA_VALIDACION` datetime DEFAULT NULL,
  `ELIMINADO` tinyint(1) NOT NULL DEFAULT 0,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_EMPLEADO_DOCUMENTO`),
  KEY `FK_BBF_DOCS_CARGADO_POR` (`ID_CARGADO_POR`),
  KEY `FK_BBF_DOCS_VALIDADO_POR` (`ID_VALIDADO_POR`),
  KEY `IDX_BBF_DOCUMENTOS_EMPLEADO` (`ID_EMPLEADO`),
  KEY `IDX_BBF_DOCUMENTOS_TIPO` (`ID_TIPO_DOCUMENTO_LABORAL`),
  KEY `IDX_BBF_DOCUMENTOS_ESTADO` (`ESTADO_DOCUMENTO`),
  KEY `IDX_BBF_DOCUMENTOS_VENCIMIENTO` (`FECHA_VENCIMIENTO`),
  KEY `IDX_BBF_DOCS_CONTRATO` (`ID_EMPLEADO_CONTRATO`),
  CONSTRAINT `FK_BBF_DOCS_CARGADO_POR` FOREIGN KEY (`ID_CARGADO_POR`) REFERENCES `bbf_usuarios` (`ID_USUARIO`),
  CONSTRAINT `FK_BBF_DOCS_CONTRATO` FOREIGN KEY (`ID_EMPLEADO_CONTRATO`) REFERENCES `bbf_empleado_contratos` (`ID_EMPLEADO_CONTRATO`),
  CONSTRAINT `FK_BBF_DOCS_EMPLEADO` FOREIGN KEY (`ID_EMPLEADO`) REFERENCES `bbf_empleados` (`ID_EMPLEADO`),
  CONSTRAINT `FK_BBF_DOCS_TIPO` FOREIGN KEY (`ID_TIPO_DOCUMENTO_LABORAL`) REFERENCES `bbf_tipos_documento_laboral` (`ID_TIPO_DOCUMENTO_LABORAL`),
  CONSTRAINT `FK_BBF_DOCS_VALIDADO_POR` FOREIGN KEY (`ID_VALIDADO_POR`) REFERENCES `bbf_usuarios` (`ID_USUARIO`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_empleado_documentos`
--

LOCK TABLES `bbf_empleado_documentos` WRITE;
/*!40000 ALTER TABLE `bbf_empleado_documentos` DISABLE KEYS */;
/*!40000 ALTER TABLE `bbf_empleado_documentos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_empleado_dotacion_articulo_tallas`
--

DROP TABLE IF EXISTS `bbf_empleado_dotacion_articulo_tallas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_empleado_dotacion_articulo_tallas` (
  `ID_EMPLEADO_DOTACION_ARTICULO_TALLA` int(11) NOT NULL AUTO_INCREMENT,
  `ID_EMPLEADO` int(11) NOT NULL,
  `ID_DOTACION_ARTICULO` int(11) NOT NULL,
  `ID_TIPO_DOTACION` int(11) NOT NULL,
  `ID_TALLA_DOTACION` int(11) NOT NULL,
  `OBSERVACIONES` varchar(250) DEFAULT NULL,
  `ACTUALIZADO_POR_USUARIO` int(11) DEFAULT NULL,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_EMPLEADO_DOTACION_ARTICULO_TALLA`),
  UNIQUE KEY `UQ_BBF_EMP_DOT_ARTICULO` (`ID_EMPLEADO`,`ID_DOTACION_ARTICULO`),
  KEY `IDX_BBF_EMP_DOT_ART_TALLA` (`ID_TALLA_DOTACION`,`ID_TIPO_DOTACION`),
  KEY `IDX_BBF_EMP_DOT_ART_ARTICULO` (`ID_DOTACION_ARTICULO`,`ID_TIPO_DOTACION`),
  KEY `IDX_BBF_EMP_DOT_ART_USUARIO` (`ACTUALIZADO_POR_USUARIO`),
  CONSTRAINT `FK_BBF_EMP_DOT_ART_ARTICULO_TIPO` FOREIGN KEY (`ID_DOTACION_ARTICULO`, `ID_TIPO_DOTACION`) REFERENCES `bbf_dotacion_articulos` (`ID_DOTACION_ARTICULO`, `ID_TIPO_DOTACION`),
  CONSTRAINT `FK_BBF_EMP_DOT_ART_EMPLEADO` FOREIGN KEY (`ID_EMPLEADO`) REFERENCES `bbf_empleados` (`ID_EMPLEADO`),
  CONSTRAINT `FK_BBF_EMP_DOT_ART_TALLA_TIPO` FOREIGN KEY (`ID_TALLA_DOTACION`, `ID_TIPO_DOTACION`) REFERENCES `bbf_tallas_dotacion` (`ID_TALLA_DOTACION`, `ID_TIPO_DOTACION`),
  CONSTRAINT `FK_BBF_EMP_DOT_ART_USUARIO` FOREIGN KEY (`ACTUALIZADO_POR_USUARIO`) REFERENCES `bbf_usuarios` (`ID_USUARIO`)
) ENGINE=InnoDB AUTO_INCREMENT=167 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_empleado_dotacion_articulo_tallas`
--

LOCK TABLES `bbf_empleado_dotacion_articulo_tallas` WRITE;
/*!40000 ALTER TABLE `bbf_empleado_dotacion_articulo_tallas` DISABLE KEYS */;
INSERT INTO `bbf_empleado_dotacion_articulo_tallas` VALUES (1,4,43,2,97,NULL,15,'2026-08-11 10:41:26',NULL),(2,4,45,1,13,NULL,15,'2026-08-11 10:41:26',NULL),(3,4,18,3,36,NULL,15,'2026-08-11 10:41:26',NULL),(4,5,30,9,81,NULL,15,'2026-08-11 10:41:26',NULL),(5,5,17,3,39,NULL,15,'2026-08-11 10:41:26',NULL),(6,6,43,2,102,NULL,15,'2026-08-11 10:41:26',NULL),(7,6,45,1,17,NULL,15,'2026-08-11 10:41:26',NULL),(8,6,18,3,40,NULL,15,'2026-08-11 10:41:26',NULL),(9,7,42,9,89,NULL,15,'2026-08-11 10:41:26',NULL),(10,7,46,3,37,NULL,15,'2026-08-11 10:41:26',NULL),(11,8,33,9,93,NULL,15,'2026-08-11 10:41:26',NULL),(12,8,18,3,32,NULL,15,'2026-08-11 10:41:26',NULL),(13,9,39,2,97,NULL,15,'2026-08-11 10:41:26',NULL),(14,9,25,1,9,NULL,15,'2026-08-11 10:41:26',NULL),(15,9,31,9,78,NULL,15,'2026-08-11 10:41:26',NULL),(16,9,20,3,35,NULL,15,'2026-08-11 10:41:26',NULL),(17,10,36,2,102,NULL,15,'2026-08-11 10:41:26',NULL),(18,10,25,1,13,NULL,15,'2026-08-11 10:41:26',NULL),(19,10,29,7,14,NULL,15,'2026-08-11 10:41:26',NULL),(20,10,18,3,40,NULL,15,'2026-08-11 10:41:26',NULL),(21,11,36,2,105,NULL,15,'2026-08-11 10:41:26',NULL),(22,11,25,1,13,NULL,15,'2026-08-11 10:41:26',NULL),(23,11,35,9,94,NULL,15,'2026-08-11 10:41:26',NULL),(24,11,19,3,37,NULL,15,'2026-08-11 10:41:26',NULL),(25,12,43,2,106,NULL,15,'2026-08-11 10:41:26',NULL),(26,12,44,1,9,NULL,15,'2026-08-11 10:41:26',NULL),(27,13,43,2,104,NULL,15,'2026-08-11 10:41:26',NULL),(28,13,45,1,21,NULL,15,'2026-08-11 10:41:26',NULL),(29,14,31,9,88,NULL,15,'2026-08-11 10:41:26',NULL),(30,14,17,3,32,NULL,15,'2026-08-11 10:41:26',NULL),(31,15,43,2,107,NULL,15,'2026-08-11 10:41:26',NULL),(32,15,44,1,9,NULL,15,'2026-08-11 10:41:26',NULL),(33,16,33,9,92,NULL,15,'2026-08-11 10:41:26',NULL),(34,16,20,3,34,NULL,15,'2026-08-11 10:41:26',NULL),(35,16,18,3,34,NULL,15,'2026-08-11 10:41:26',NULL),(36,17,30,9,81,NULL,15,'2026-08-11 10:41:26',NULL),(37,17,19,3,37,NULL,15,'2026-08-11 10:41:26',NULL),(38,18,30,9,84,NULL,15,'2026-08-11 10:41:26',NULL),(39,18,32,9,90,NULL,15,'2026-08-11 10:41:26',NULL),(40,18,19,3,38,NULL,15,'2026-08-11 10:41:26',NULL),(41,19,30,9,81,NULL,15,'2026-08-11 10:41:26',NULL),(42,19,19,3,36,NULL,15,'2026-08-11 10:41:26',NULL),(43,20,30,9,82,NULL,15,'2026-08-11 10:41:26',NULL),(44,20,19,3,39,NULL,15,'2026-08-11 10:41:26',NULL),(45,21,30,9,81,NULL,15,'2026-08-11 10:41:26',NULL),(46,21,19,3,36,NULL,15,'2026-08-11 10:41:26',NULL),(47,22,16,10,75,NULL,15,'2026-08-11 10:41:26',NULL),(48,22,18,3,36,NULL,15,'2026-08-11 10:41:26',NULL),(49,23,16,10,75,NULL,15,'2026-08-11 10:41:26',NULL),(50,23,18,3,34,NULL,15,'2026-08-11 10:41:26',NULL),(51,24,30,9,83,NULL,15,'2026-08-11 10:41:26',NULL),(52,24,17,3,37,NULL,15,'2026-08-11 10:41:26',NULL),(53,25,31,9,77,NULL,15,'2026-08-11 10:41:26',NULL),(54,25,20,3,33,NULL,15,'2026-08-11 10:41:26',NULL),(55,26,31,9,78,NULL,15,'2026-08-11 10:41:26',NULL),(56,26,20,3,35,NULL,15,'2026-08-11 10:41:26',NULL),(57,27,30,9,82,NULL,15,'2026-08-11 10:41:26',NULL),(58,27,19,3,37,NULL,15,'2026-08-11 10:41:26',NULL),(59,28,30,9,82,NULL,15,'2026-08-11 10:41:26',NULL),(60,28,19,3,37,NULL,15,'2026-08-11 10:41:26',NULL),(61,29,30,9,82,NULL,15,'2026-08-11 10:41:26',NULL),(62,29,19,3,36,NULL,15,'2026-08-11 10:41:26',NULL),(63,30,25,1,9,NULL,15,'2026-08-11 10:41:26',NULL),(64,30,16,10,75,NULL,15,'2026-08-11 10:41:26',NULL),(65,31,16,10,66,NULL,15,'2026-08-11 10:41:26',NULL),(66,31,19,3,38,NULL,15,'2026-08-11 10:41:26',NULL),(67,32,16,10,67,NULL,15,'2026-08-11 10:41:26',NULL),(68,32,19,3,36,NULL,15,'2026-08-11 10:41:26',NULL),(69,33,31,9,88,NULL,15,'2026-08-11 10:41:26',NULL),(70,33,17,3,35,NULL,15,'2026-08-11 10:41:26',NULL),(71,34,31,9,87,NULL,15,'2026-08-11 10:41:26',NULL),(72,34,20,3,33,NULL,15,'2026-08-11 10:41:26',NULL),(73,35,39,2,98,NULL,15,'2026-08-11 10:41:26',NULL),(74,35,25,1,9,NULL,15,'2026-08-11 10:41:26',NULL),(75,35,31,9,79,NULL,15,'2026-08-11 10:41:26',NULL),(76,35,17,3,35,NULL,15,'2026-08-11 10:41:26',NULL),(77,36,25,1,9,NULL,15,'2026-08-11 10:41:26',NULL),(78,36,16,10,74,NULL,15,'2026-08-11 10:41:26',NULL),(79,37,16,10,75,NULL,15,'2026-08-11 10:41:26',NULL),(80,37,20,3,37,NULL,15,'2026-08-11 10:41:26',NULL),(81,38,30,9,83,NULL,15,'2026-08-11 10:41:26',NULL),(82,38,19,3,37,NULL,15,'2026-08-11 10:41:26',NULL),(83,40,16,10,69,NULL,15,'2026-08-11 10:41:26',NULL),(84,40,18,3,32,NULL,15,'2026-08-11 10:41:26',NULL),(85,41,30,9,84,NULL,15,'2026-08-11 10:41:26',NULL),(86,41,19,3,37,NULL,15,'2026-08-11 10:41:26',NULL),(87,42,30,9,83,NULL,15,'2026-08-11 10:41:26',NULL),(88,42,19,3,40,NULL,15,'2026-08-11 10:41:26',NULL),(89,43,30,9,84,NULL,15,'2026-08-11 10:41:26',NULL),(90,43,17,3,41,NULL,15,'2026-08-11 10:41:26',NULL),(91,44,16,10,65,NULL,15,'2026-08-11 10:41:26',NULL),(92,44,19,3,40,NULL,15,'2026-08-11 10:41:26',NULL),(93,44,18,3,39,NULL,15,'2026-08-11 10:41:26',NULL),(94,45,36,2,101,NULL,15,'2026-08-11 10:41:26',NULL),(95,45,25,1,13,NULL,15,'2026-08-11 10:41:26',NULL),(96,45,29,7,14,NULL,15,'2026-08-11 10:41:26',NULL),(97,45,18,3,38,NULL,15,'2026-08-11 10:41:26',NULL),(98,46,31,9,78,NULL,15,'2026-08-11 10:41:26',NULL),(99,46,20,3,35,NULL,15,'2026-08-11 10:41:26',NULL),(100,48,31,9,77,NULL,15,'2026-08-11 10:41:26',NULL),(101,48,17,3,32,NULL,15,'2026-08-11 10:41:26',NULL),(102,49,31,9,78,NULL,15,'2026-08-11 10:41:26',NULL),(103,49,20,3,34,NULL,15,'2026-08-11 10:41:26',NULL),(104,50,31,9,77,NULL,15,'2026-08-11 10:41:26',NULL),(105,50,20,3,35,NULL,15,'2026-08-11 10:41:26',NULL),(106,51,30,9,82,NULL,15,'2026-08-11 10:41:26',NULL),(107,51,19,3,38,NULL,15,'2026-08-11 10:41:26',NULL),(108,52,31,9,77,NULL,15,'2026-08-11 10:41:26',NULL),(109,52,17,3,35,NULL,15,'2026-08-11 10:41:26',NULL),(110,53,30,9,82,NULL,15,'2026-08-11 10:41:26',NULL),(111,53,19,3,41,NULL,15,'2026-08-11 10:41:26',NULL),(112,54,16,10,70,NULL,15,'2026-08-11 10:41:26',NULL),(113,54,17,3,37,NULL,15,'2026-08-11 10:41:26',NULL),(114,55,36,2,99,NULL,15,'2026-08-11 10:41:26',NULL),(115,55,25,1,9,NULL,15,'2026-08-11 10:41:26',NULL),(116,55,19,3,37,NULL,15,'2026-08-11 10:41:26',NULL),(117,56,30,9,81,NULL,15,'2026-08-11 10:41:26',NULL),(118,56,19,3,38,NULL,15,'2026-08-11 10:41:26',NULL),(119,57,36,2,105,NULL,15,'2026-08-11 10:41:26',NULL),(120,57,25,1,21,NULL,15,'2026-08-11 10:41:26',NULL),(121,57,30,9,86,NULL,15,'2026-08-11 10:41:26',NULL),(122,57,19,3,38,NULL,15,'2026-08-11 10:41:26',NULL),(123,58,31,9,77,NULL,15,'2026-08-11 10:41:26',NULL),(124,58,20,3,37,NULL,15,'2026-08-11 10:41:26',NULL),(125,59,36,2,99,NULL,15,'2026-08-11 10:41:26',NULL),(126,59,25,1,5,NULL,15,'2026-08-11 10:41:26',NULL),(127,59,19,3,36,NULL,15,'2026-08-11 10:41:26',NULL),(128,60,25,1,9,NULL,15,'2026-08-11 10:41:26',NULL),(129,60,16,10,73,NULL,15,'2026-08-11 10:41:26',NULL),(130,60,20,3,35,NULL,15,'2026-08-11 10:41:26',NULL),(131,61,16,10,66,NULL,15,'2026-08-11 10:41:26',NULL),(132,61,17,3,39,NULL,15,'2026-08-11 10:41:26',NULL),(133,62,30,9,81,NULL,15,'2026-08-11 10:41:26',NULL),(134,62,19,3,37,NULL,15,'2026-08-11 10:41:26',NULL),(135,63,31,9,88,NULL,15,'2026-08-11 10:41:26',NULL),(136,63,20,3,34,NULL,15,'2026-08-11 10:41:26',NULL),(137,64,30,9,81,NULL,15,'2026-08-11 10:41:26',NULL),(138,64,19,3,37,NULL,15,'2026-08-11 10:41:26',NULL),(139,65,16,10,66,NULL,15,'2026-08-11 10:41:26',NULL),(140,65,17,3,40,NULL,15,'2026-08-11 10:41:26',NULL),(141,66,43,2,107,NULL,15,'2026-08-11 10:41:26',NULL),(142,66,45,1,9,NULL,15,'2026-08-11 10:41:26',NULL),(143,66,18,3,32,NULL,15,'2026-08-11 10:41:26',NULL),(144,67,30,9,80,NULL,15,'2026-08-11 10:41:26',NULL),(145,67,19,3,36,NULL,15,'2026-08-11 10:41:26',NULL),(146,68,31,9,88,NULL,15,'2026-08-11 10:41:26',NULL),(147,68,17,3,34,NULL,15,'2026-08-11 10:41:26',NULL),(148,69,30,9,80,NULL,15,'2026-08-11 10:41:26',NULL),(149,69,17,3,36,NULL,15,'2026-08-11 10:41:26',NULL),(150,71,30,9,81,NULL,15,'2026-08-11 10:41:26',NULL),(151,71,19,3,38,NULL,15,'2026-08-11 10:41:26',NULL),(152,72,16,10,67,NULL,15,'2026-08-11 10:41:26',NULL),(153,72,17,3,33,NULL,15,'2026-08-11 10:41:26',NULL),(154,73,16,10,66,NULL,15,'2026-08-11 10:41:26',NULL),(155,73,17,3,36,NULL,15,'2026-08-11 10:41:26',NULL),(156,74,30,9,83,NULL,15,'2026-08-11 10:41:26',NULL),(157,74,18,3,39,NULL,15,'2026-08-11 10:41:26',NULL),(158,75,16,10,75,NULL,15,'2026-08-11 10:41:26',NULL),(159,75,20,3,38,NULL,15,'2026-08-11 10:41:26',NULL),(160,76,36,2,101,NULL,15,'2026-08-11 10:41:26',NULL),(161,76,25,1,9,NULL,15,'2026-08-11 10:41:26',NULL),(162,76,17,3,37,NULL,15,'2026-08-11 10:41:26',NULL),(163,77,31,9,88,NULL,15,'2026-08-11 10:41:26',NULL),(164,77,20,3,35,NULL,15,'2026-08-11 10:41:26',NULL),(165,78,31,9,76,NULL,15,'2026-08-11 10:41:26',NULL),(166,78,20,3,35,NULL,15,'2026-08-11 10:41:26',NULL);
/*!40000 ALTER TABLE `bbf_empleado_dotacion_articulo_tallas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_empleado_dotacion_tallas`
--

DROP TABLE IF EXISTS `bbf_empleado_dotacion_tallas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_empleado_dotacion_tallas` (
  `ID_EMPLEADO_DOTACION_TALLA` int(11) NOT NULL AUTO_INCREMENT,
  `ID_EMPLEADO` int(11) NOT NULL,
  `ID_TIPO_DOTACION` int(11) NOT NULL,
  `ID_TALLA_DOTACION` int(11) DEFAULT NULL,
  `OBSERVACIONES` varchar(250) DEFAULT NULL,
  `ACTUALIZADO_POR_USUARIO` int(11) DEFAULT NULL,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_EMPLEADO_DOTACION_TALLA`),
  UNIQUE KEY `UQ_BBF_EMPLEADO_TIPO_DOTACION` (`ID_EMPLEADO`,`ID_TIPO_DOTACION`),
  KEY `FK_BBF_EMP_DOT_TALLAS_TIPO` (`ID_TIPO_DOTACION`),
  KEY `FK_BBF_EMP_DOT_TALLAS_TALLA` (`ID_TALLA_DOTACION`),
  KEY `FK_BBF_EMP_DOT_TALLAS_USUARIO` (`ACTUALIZADO_POR_USUARIO`),
  CONSTRAINT `FK_BBF_EMP_DOT_TALLAS_EMPLEADO` FOREIGN KEY (`ID_EMPLEADO`) REFERENCES `bbf_empleados` (`ID_EMPLEADO`),
  CONSTRAINT `FK_BBF_EMP_DOT_TALLAS_TALLA` FOREIGN KEY (`ID_TALLA_DOTACION`) REFERENCES `bbf_tallas_dotacion` (`ID_TALLA_DOTACION`),
  CONSTRAINT `FK_BBF_EMP_DOT_TALLAS_TIPO` FOREIGN KEY (`ID_TIPO_DOTACION`) REFERENCES `bbf_tipos_dotacion` (`ID_TIPO_DOTACION`),
  CONSTRAINT `FK_BBF_EMP_DOT_TALLAS_USUARIO` FOREIGN KEY (`ACTUALIZADO_POR_USUARIO`) REFERENCES `bbf_usuarios` (`ID_USUARIO`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_empleado_dotacion_tallas`
--

LOCK TABLES `bbf_empleado_dotacion_tallas` WRITE;
/*!40000 ALTER TABLE `bbf_empleado_dotacion_tallas` DISABLE KEYS */;
/*!40000 ALTER TABLE `bbf_empleado_dotacion_tallas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_empleado_examenes_medicos`
--

DROP TABLE IF EXISTS `bbf_empleado_examenes_medicos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_empleado_examenes_medicos` (
  `ID_EXAMEN_MEDICO` int(11) NOT NULL AUTO_INCREMENT,
  `ID_EMPLEADO` int(11) NOT NULL,
  `ID_TIPO_EXAMEN_MEDICO` int(11) NOT NULL,
  `FECHA_EXAMEN` date NOT NULL,
  `ENTIDAD_REALIZA` varchar(200) DEFAULT NULL,
  `RESULTADO_GENERAL` varchar(250) DEFAULT NULL,
  `FECHA_VENCIMIENTO` date DEFAULT NULL,
  `ARCHIVO_URL` varchar(500) DEFAULT NULL,
  `OBSERVACIONES` text DEFAULT NULL,
  `ELIMINADO` tinyint(1) NOT NULL DEFAULT 0,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_EXAMEN_MEDICO`),
  KEY `FK_BBF_EXAMENES_TIPO` (`ID_TIPO_EXAMEN_MEDICO`),
  KEY `IDX_BBF_EXAMENES_EMPLEADO` (`ID_EMPLEADO`),
  KEY `IDX_BBF_EXAMENES_FECHA_VENCIMIENTO` (`FECHA_VENCIMIENTO`),
  CONSTRAINT `FK_BBF_EXAMENES_EMPLEADO` FOREIGN KEY (`ID_EMPLEADO`) REFERENCES `bbf_empleados` (`ID_EMPLEADO`),
  CONSTRAINT `FK_BBF_EXAMENES_TIPO` FOREIGN KEY (`ID_TIPO_EXAMEN_MEDICO`) REFERENCES `bbf_tipos_examen_medico` (`ID_TIPO_EXAMEN_MEDICO`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_empleado_examenes_medicos`
--

LOCK TABLES `bbf_empleado_examenes_medicos` WRITE;
/*!40000 ALTER TABLE `bbf_empleado_examenes_medicos` DISABLE KEYS */;
/*!40000 ALTER TABLE `bbf_empleado_examenes_medicos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_empleado_ficha_ingreso`
--

DROP TABLE IF EXISTS `bbf_empleado_ficha_ingreso`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_empleado_ficha_ingreso` (
  `ID_FICHA_INGRESO` int(11) NOT NULL AUTO_INCREMENT,
  `ID_EMPLEADO` int(11) NOT NULL,
  `NUMERO_CARPETA` varchar(50) DEFAULT NULL,
  `GENERO` varchar(20) DEFAULT NULL,
  `FECHA_EXPEDICION_DOCUMENTO` date DEFAULT NULL,
  `FECHA_NACIMIENTO` date DEFAULT NULL,
  `ID_DEPARTAMENTO_NACIMIENTO` int(11) DEFAULT NULL,
  `ID_MUNICIPIO_NACIMIENTO` int(11) DEFAULT NULL,
  `LUGAR_NACIMIENTO` varchar(150) DEFAULT NULL,
  `NACIONALIDAD` varchar(100) DEFAULT NULL,
  `ID_DEPARTAMENTO_RESIDENCIA` int(11) DEFAULT NULL,
  `ID_MUNICIPIO_RESIDENCIA` int(11) DEFAULT NULL,
  `DEPARTAMENTO_NACIMIENTO` varchar(150) DEFAULT NULL,
  `CIUDAD_RESIDENCIA` varchar(150) DEFAULT NULL,
  `DEPARTAMENTO_RESIDENCIA` varchar(150) DEFAULT NULL,
  `DIRECCION_RESIDENCIA` varchar(250) DEFAULT NULL,
  `TELEFONO_ALTERNO` varchar(50) DEFAULT NULL,
  `CORREO_PERSONAL` varchar(150) DEFAULT NULL,
  `ESTADO_CIVIL` enum('SOLTERO','CASADO','UNION_LIBRE','SEPARADO','DIVORCIADO','VIUDO','OTRO') DEFAULT NULL,
  `NIVEL_EDUCATIVO` enum('PRIMARIA','BACHILLER','TECNICO','TECNOLOGO','PROFESIONAL','POSGRADO','NINGUNO','OTRO') DEFAULT NULL,
  `PERSONAS_A_CARGO` int(11) DEFAULT 0,
  `NUMERO_HIJOS` int(11) DEFAULT 0,
  `PERSONAS_VIVIENDA` int(10) unsigned DEFAULT NULL,
  `MENORES_ESTUDIAN` tinyint(1) DEFAULT NULL,
  `ESTADO_FICHA` enum('PENDIENTE','COMPLETA','INCOMPLETA') NOT NULL DEFAULT 'PENDIENTE',
  `OBSERVACIONES` text DEFAULT NULL,
  `ELIMINADO` tinyint(1) NOT NULL DEFAULT 0,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_FICHA_INGRESO`),
  UNIQUE KEY `UQ_BBF_FICHA_INGRESO_EMPLEADO` (`ID_EMPLEADO`),
  KEY `IDX_BBF_FICHA_INGRESO_EMPLEADO` (`ID_EMPLEADO`),
  KEY `FK_BBF_FICHA_DEP_NAC` (`ID_DEPARTAMENTO_NACIMIENTO`),
  KEY `FK_BBF_FICHA_MUN_NAC` (`ID_MUNICIPIO_NACIMIENTO`),
  KEY `FK_BBF_FICHA_DEP_RES` (`ID_DEPARTAMENTO_RESIDENCIA`),
  KEY `FK_BBF_FICHA_MUN_RES` (`ID_MUNICIPIO_RESIDENCIA`),
  CONSTRAINT `FK_BBF_FICHA_DEP_NAC` FOREIGN KEY (`ID_DEPARTAMENTO_NACIMIENTO`) REFERENCES `bbf_departamentos` (`ID_DEPARTAMENTO`),
  CONSTRAINT `FK_BBF_FICHA_DEP_RES` FOREIGN KEY (`ID_DEPARTAMENTO_RESIDENCIA`) REFERENCES `bbf_departamentos` (`ID_DEPARTAMENTO`),
  CONSTRAINT `FK_BBF_FICHA_INGRESO_EMPLEADO` FOREIGN KEY (`ID_EMPLEADO`) REFERENCES `bbf_empleados` (`ID_EMPLEADO`),
  CONSTRAINT `FK_BBF_FICHA_MUN_NAC` FOREIGN KEY (`ID_MUNICIPIO_NACIMIENTO`) REFERENCES `bbf_municipios` (`ID_MUNICIPIO`),
  CONSTRAINT `FK_BBF_FICHA_MUN_RES` FOREIGN KEY (`ID_MUNICIPIO_RESIDENCIA`) REFERENCES `bbf_municipios` (`ID_MUNICIPIO`)
) ENGINE=InnoDB AUTO_INCREMENT=79 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_empleado_ficha_ingreso`
--

LOCK TABLES `bbf_empleado_ficha_ingreso` WRITE;
/*!40000 ALTER TABLE `bbf_empleado_ficha_ingreso` DISABLE KEYS */;
INSERT INTO `bbf_empleado_ficha_ingreso` VALUES (3,3,'1','F','2008-05-23','1990-04-22',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'FINCA BARRO BLANCO VDA SAN JOSE',NULL,NULL,NULL,NULL,NULL,NULL,4,1,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(4,4,'2','F','2005-01-18','1986-09-10',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'sector camacho vereda astorga',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(5,5,'3','M','1989-12-11','1969-04-13',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'vereda san jose',NULL,NULL,NULL,NULL,NULL,NULL,2,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(6,6,'4','M','2007-06-25','1989-05-08',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'sector camacho vereda astorga',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(7,7,'5','F','1994-11-15','1973-08-08',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'vereda san jose',NULL,NULL,NULL,NULL,NULL,NULL,2,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(8,8,'6','F','2008-01-18','1989-09-13',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'VEREDA SAN JOSE',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(9,9,'7','F','1990-10-05','1972-07-15',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'calle 3 n 2 a 03',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(10,10,'8','M','2003-02-24','1984-04-24',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Vereda la fuente',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(11,11,'9','M','1993-07-30','1974-12-26',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Vereda la fuente',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(12,12,'10','F','2014-12-09','1996-12-06',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Calle 1 a sur 2 25 torre 8 apto 202',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(13,13,'11','M','2019-12-30','1994-01-30',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'keranta gran camino',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(14,14,'12','F','1994-06-20','1976-01-30',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Villa de los sauces',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(15,15,'13','F','2020-06-23','2002-06-20',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'CALLE 3 6 76',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(16,16,'14','F','2007-05-30','1989-05-18',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'CARRERA 5 2 35',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(17,17,'15','M','1993-11-30','1973-11-16',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ROBLE CENTRO',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(18,18,'16','M','2000-09-05','1982-06-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'VEREDA ROBLE CENTRO',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(19,19,'17','M','1997-08-04',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'VEREDA LA FUENTE',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(20,20,'18','M','1992-10-30','1973-07-28',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'VRDA SAN BARTOLOME BAJO',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(21,21,'19','M','1988-10-25','1969-05-16',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'vereda san jose',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(22,22,'20','F','2019-08-20','1995-11-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'vereda santa barbara',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(23,23,'21','F','1999-04-09','1981-01-06',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'VEREDA LA FUENTE',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(24,24,'22','M','1989-05-25','1970-02-12',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'calle 2 2 16',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(25,25,'23','F','2002-02-13','1983-12-16',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'vereda san martin',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(26,26,'24','F','2014-03-26','1995-12-02',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'CALLE 2 B 3 06',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(27,27,'25','M','2015-07-16','1997-07-09',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'SANTA BARBARA',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(28,28,'26','M','2019-08-16','2001-08-14',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'VEREDA SANTA BARBARA',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(29,29,'27','M','2006-12-03','1988-01-18',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'VEREDA ROBLE CENTRO',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(30,30,'28','F','2012-08-10','1994-08-06',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Vereda san martin',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(31,31,'29','M','2023-01-31','1988-10-29',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'VEREDA SAN JOSE',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(32,32,'30','M','2023-03-31','1990-09-14',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'vereda san jose',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(33,33,'31','F','1990-08-31','1971-05-15',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'carrera 1 3-43',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(34,34,'32','F','2009-11-17','1991-10-03',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'vereda santa barbara',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(35,35,'33','F','2006-05-16','1988-04-12',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'SAN JORGE',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(36,36,'34','F','2007-01-25','1988-10-13',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'SANTA ANA',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(37,37,'35','F','2018-06-08','1997-11-18',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'centros',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(38,38,'36','M','1996-04-08','1977-03-18',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'VRD ROBLE CENTRO',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(39,39,'37','F','2013-05-07','1995-05-06',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'CALLE 26 14 41',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(40,40,'38','F','2005-12-12','1987-08-12',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'transversal 2 n 6 85',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(41,41,'39','M','1995-01-20','1972-05-07',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'carrera 5 -5-10',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(42,42,'40','M','1991-07-27','1972-06-05',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'cra 2 B. No 1035',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(43,43,'42','M','1999-01-18','1980-09-27',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'vereda san jose',NULL,NULL,NULL,NULL,NULL,NULL,4,1,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(44,44,'43','M',NULL,'1995-06-21',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'vereda san jose',NULL,NULL,NULL,NULL,NULL,NULL,2,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(45,45,'44','M','2001-06-12','1983-03-06',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'VEREDA CAMACHO',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(46,46,'45','F','1993-06-30','1975-01-04',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'CALLE 35 A # 68 B 47',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(47,47,'46','M','1994-02-07',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'CALLE 7 15-11',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(48,48,'47','F','1999-11-04','1980-10-11',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'VDA LAS MERCEDES',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(49,49,'48','F','2007-09-27','1989-09-14',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'keranta gran resplandor',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(50,50,'49','F','1999-01-15','1979-04-07',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'carrera 5 1-10',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(51,51,'50','M','1991-08-02','1973-03-09',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'vereda la fuente',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(52,52,'51','F','2010-01-28','1992-01-27',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'calle 1 a sur 2 25',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(53,53,'52','M','2015-01-14','1997-01-02',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'VEREDA SAN MARTIN',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(54,54,'53','M','2020-03-06','1984-02-12',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'BELEN',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(55,55,'54','M','2015-02-03','1997-01-17',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'vereda san jose',NULL,NULL,NULL,NULL,NULL,NULL,3,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(56,56,'55','M','2020-03-03','1997-04-12',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'santa ana',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(57,57,'56','M','2000-05-23','1982-04-03',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'vereda santa barbara',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(58,58,'57','F','2021-11-08','1999-10-26',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'CALLE 4 N. 208',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(59,59,'58','M','2014-07-01','1996-06-24',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'vereda la aurora',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(60,60,'59','F','2000-02-21','1981-04-06',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'CALLE 4 7 65',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(61,61,'60','M','2020-12-24','2002-12-18',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'centro',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(62,62,'61','M','2002-03-22','1982-08-11',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'CARRERA 2 C 2 A 35',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(63,63,'62','F','2012-06-16','1993-01-10',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'VEREDA SANTA BARBARA',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(64,64,'63','M','2026-01-28','2008-01-22',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'calle 3 a 6-89 sur',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(65,65,'64','M','2002-10-08','1984-05-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'calle 1 a sur 2 25|',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(66,66,'65','F','2002-07-23','1984-05-15',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'pueblo viejo',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(67,67,'67','M','2017-03-08','1999-02-28',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'las delicias',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(68,68,'68','F','2006-10-02','1986-12-13',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'conjunto gaika',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(69,69,'69','M','2003-09-10','1985-08-10',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'transversal 2 # 6-85',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(70,70,'70','F','2025-01-21','2004-01-18',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'VEREDA LA FUENTE',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(71,71,'71','M','2020-11-24','2002-07-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'KERANTA ENTRE LUNAS',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(72,72,'72','F','2019-01-28','2001-01-27',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'CARRERA 5 A 3 35',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(73,73,'73','F','1994-06-20','1973-11-11',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'vereda san martin',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(74,74,'74','M','1999-09-09','1981-06-23',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'vereda san bartolome',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(75,75,'75','F','2024-06-20','2006-05-08',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'CRA 3 # 8-09 SAN MARTIN',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(76,76,'76','M','2015-06-01','1985-05-09',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'KERANTA GRAN CAMINO',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(77,77,'77','F','2024-12-02','2006-12-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'VEREDA LA FUENTE',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL),(78,78,'78','F','2010-05-25','1992-05-25',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'veredasan martin',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'INCOMPLETA',NULL,0,'2026-08-11 10:41:26',NULL);
/*!40000 ALTER TABLE `bbf_empleado_ficha_ingreso` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_empleado_seguridad_social`
--

DROP TABLE IF EXISTS `bbf_empleado_seguridad_social`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_empleado_seguridad_social` (
  `ID_SEGURIDAD_SOCIAL` int(11) NOT NULL AUTO_INCREMENT,
  `ID_EMPLEADO` int(11) NOT NULL,
  `ID_EPS` int(11) DEFAULT NULL,
  `ID_ARL` int(11) DEFAULT NULL,
  `ID_FONDO_PENSION` int(11) DEFAULT NULL,
  `ID_FONDO_CESANTIAS` int(11) DEFAULT NULL,
  `ID_CAJA_COMPENSACION` int(11) DEFAULT NULL,
  `FECHA_AFILIACION_EPS` date DEFAULT NULL,
  `FECHA_AFILIACION_ARL` date DEFAULT NULL,
  `FECHA_AFILIACION_PENSION` date DEFAULT NULL,
  `FECHA_AFILIACION_CESANTIAS` date DEFAULT NULL,
  `FECHA_AFILIACION_CAJA` date DEFAULT NULL,
  `OBSERVACIONES` text DEFAULT NULL,
  `ELIMINADO` tinyint(1) NOT NULL DEFAULT 0,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_SEGURIDAD_SOCIAL`),
  UNIQUE KEY `UQ_BBF_SEG_SOCIAL_EMPLEADO` (`ID_EMPLEADO`),
  KEY `FK_BBF_SEG_SOCIAL_EPS` (`ID_EPS`),
  KEY `FK_BBF_SEG_SOCIAL_ARL` (`ID_ARL`),
  KEY `FK_BBF_SEG_SOCIAL_PENSION` (`ID_FONDO_PENSION`),
  KEY `FK_BBF_SEG_SOCIAL_CESANTIAS` (`ID_FONDO_CESANTIAS`),
  KEY `FK_BBF_SEG_SOCIAL_CAJA` (`ID_CAJA_COMPENSACION`),
  KEY `IDX_BBF_SEG_SOCIAL_EMPLEADO` (`ID_EMPLEADO`),
  CONSTRAINT `FK_BBF_SEG_SOCIAL_ARL` FOREIGN KEY (`ID_ARL`) REFERENCES `bbf_entidades_seguridad_social` (`ID_ENTIDAD_SEGURIDAD_SOCIAL`),
  CONSTRAINT `FK_BBF_SEG_SOCIAL_CAJA` FOREIGN KEY (`ID_CAJA_COMPENSACION`) REFERENCES `bbf_entidades_seguridad_social` (`ID_ENTIDAD_SEGURIDAD_SOCIAL`),
  CONSTRAINT `FK_BBF_SEG_SOCIAL_CESANTIAS` FOREIGN KEY (`ID_FONDO_CESANTIAS`) REFERENCES `bbf_entidades_seguridad_social` (`ID_ENTIDAD_SEGURIDAD_SOCIAL`),
  CONSTRAINT `FK_BBF_SEG_SOCIAL_EMPLEADO` FOREIGN KEY (`ID_EMPLEADO`) REFERENCES `bbf_empleados` (`ID_EMPLEADO`),
  CONSTRAINT `FK_BBF_SEG_SOCIAL_EPS` FOREIGN KEY (`ID_EPS`) REFERENCES `bbf_entidades_seguridad_social` (`ID_ENTIDAD_SEGURIDAD_SOCIAL`),
  CONSTRAINT `FK_BBF_SEG_SOCIAL_PENSION` FOREIGN KEY (`ID_FONDO_PENSION`) REFERENCES `bbf_entidades_seguridad_social` (`ID_ENTIDAD_SEGURIDAD_SOCIAL`)
) ENGINE=InnoDB AUTO_INCREMENT=79 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_empleado_seguridad_social`
--

LOCK TABLES `bbf_empleado_seguridad_social` WRITE;
/*!40000 ALTER TABLE `bbf_empleado_seguridad_social` DISABLE KEYS */;
INSERT INTO `bbf_empleado_seguridad_social` VALUES (3,3,32,8,35,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(4,4,1,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(5,5,1,8,12,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(6,6,5,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(7,7,1,8,12,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(8,8,3,8,12,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(9,9,5,8,13,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(10,10,34,8,12,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(11,11,3,8,12,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(12,12,34,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(13,13,3,8,12,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(14,14,3,8,12,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(15,15,4,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(16,16,1,8,12,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(17,17,1,8,12,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(18,18,3,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(19,19,5,8,12,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(20,20,3,8,12,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(21,21,3,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(22,22,5,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(23,23,34,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(24,24,5,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(25,25,1,8,12,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(26,26,5,8,12,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(27,27,1,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(28,28,3,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(29,29,1,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(30,30,1,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(31,31,1,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(32,32,34,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(33,33,5,8,12,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(34,34,1,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(35,35,5,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(36,36,5,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(37,37,1,8,12,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(38,38,5,8,12,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(39,39,5,8,12,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(40,40,5,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(41,41,5,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(42,42,5,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(43,43,1,8,12,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(44,44,34,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(45,45,1,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(46,46,1,8,35,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(47,47,2,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(48,48,1,8,12,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(49,49,5,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(50,50,1,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(51,51,5,8,13,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(52,52,1,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(53,53,5,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(54,54,3,8,12,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(55,55,34,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(56,56,5,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(57,57,3,8,12,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(58,58,3,8,12,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(59,59,1,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(60,60,5,8,35,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(61,61,6,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(62,62,1,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(63,63,3,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(64,64,33,8,12,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(65,65,5,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(66,66,4,8,13,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(67,67,1,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(68,68,1,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(69,69,1,8,12,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(70,70,4,8,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(71,71,1,8,12,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(72,72,5,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(73,73,4,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(74,74,4,8,12,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(75,75,5,8,13,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(76,76,1,8,12,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(77,77,1,8,13,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL),(78,78,34,8,11,15,36,NULL,NULL,NULL,NULL,NULL,NULL,0,'2026-08-11 10:41:26',NULL);
/*!40000 ALTER TABLE `bbf_empleado_seguridad_social` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_empleados`
--

DROP TABLE IF EXISTS `bbf_empleados`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_empleados` (
  `ID_EMPLEADO` int(11) NOT NULL AUTO_INCREMENT,
  `ID_ASPIRANTE_ORIGEN` int(11) DEFAULT NULL,
  `ID_TIPO_DOCUMENTO` int(11) DEFAULT NULL,
  `NUMERO_DOCUMENTO` varchar(50) NOT NULL,
  `NOMBRES` varchar(150) NOT NULL,
  `APELLIDOS` varchar(150) NOT NULL,
  `CORREO` varchar(150) DEFAULT NULL,
  `TELEFONO` varchar(50) DEFAULT NULL,
  `FOTO_URL` varchar(500) DEFAULT NULL,
  `ID_AREA` int(11) DEFAULT NULL,
  `ID_CARGO` int(11) DEFAULT NULL,
  `ID_TIPO_CONTRATO` int(11) DEFAULT NULL,
  `FECHA_INGRESO` date DEFAULT NULL,
  `FECHA_RETIRO` date DEFAULT NULL,
  `ESTADO_EMPLEADO` enum('ACTIVO','RETIRADO','SUSPENDIDO','INCAPACITADO','EN_PROCESO_RETIRO') NOT NULL DEFAULT 'ACTIVO',
  `OBSERVACIONES` text DEFAULT NULL,
  `ELIMINADO` tinyint(1) NOT NULL DEFAULT 0,
  `FECHA_ELIMINACION` datetime DEFAULT NULL,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_EMPLEADO`),
  UNIQUE KEY `UQ_BBF_EMPLEADOS_DOCUMENTO` (`NUMERO_DOCUMENTO`),
  KEY `FK_BBF_EMPLEADOS_TIPO_DOCUMENTO` (`ID_TIPO_DOCUMENTO`),
  KEY `FK_BBF_EMPLEADOS_AREA` (`ID_AREA`),
  KEY `FK_BBF_EMPLEADOS_CARGO` (`ID_CARGO`),
  KEY `FK_BBF_EMPLEADOS_TIPO_CONTRATO` (`ID_TIPO_CONTRATO`),
  KEY `FK_BBF_EMPLEADOS_ASPIRANTE_ORIGEN` (`ID_ASPIRANTE_ORIGEN`),
  CONSTRAINT `FK_BBF_EMPLEADOS_AREA` FOREIGN KEY (`ID_AREA`) REFERENCES `bbf_areas` (`ID_AREA`),
  CONSTRAINT `FK_BBF_EMPLEADOS_ASPIRANTE_ORIGEN` FOREIGN KEY (`ID_ASPIRANTE_ORIGEN`) REFERENCES `bbf_aspirantes` (`ID_ASPIRANTE`),
  CONSTRAINT `FK_BBF_EMPLEADOS_CARGO` FOREIGN KEY (`ID_CARGO`) REFERENCES `bbf_cargos` (`ID_CARGO`),
  CONSTRAINT `FK_BBF_EMPLEADOS_TIPO_CONTRATO` FOREIGN KEY (`ID_TIPO_CONTRATO`) REFERENCES `bbf_tipos_contrato` (`ID_TIPO_CONTRATO`),
  CONSTRAINT `FK_BBF_EMPLEADOS_TIPO_DOCUMENTO` FOREIGN KEY (`ID_TIPO_DOCUMENTO`) REFERENCES `bbf_tipos_documento` (`ID_TIPO_DOCUMENTO`)
) ENGINE=InnoDB AUTO_INCREMENT=79 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_empleados`
--

LOCK TABLES `bbf_empleados` WRITE;
/*!40000 ALTER TABLE `bbf_empleados` DISABLE KEYS */;
INSERT INTO `bbf_empleados` VALUES (3,NULL,2,'1075661055','YULIANA LICETTE','VILLARRAGA GOMEZ','barroblancofarms@gmail.com','3142473591','/uploads/employees/employee_3_20260811154141.png',2,44,2,'2015-02-01',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26','2026-08-11 10:41:42'),(4,NULL,2,'1069098313','MAGALY','PRIETO JULIETH','prietomagaly18@gmail.com','3012265247',NULL,5,7,2,'2016-07-18',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(5,NULL,2,'5950784','NILSON','VELOZA RIVERA','velosanilson248@gmail.com','3112581215',NULL,5,8,2,'2016-11-11',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(6,NULL,2,'1069099002','ALBERTO','PRIETO YEISSON','yeisson.prietp@gmail.com','3173679830',NULL,5,53,2,'2017-09-05',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(7,NULL,2,'39809352','LUZ MERY','ORJUELA PIÑEROS','luzmeryorjuela91@gmail.com','3143428290',NULL,2,51,2,'2017-08-02',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(8,NULL,2,'1073532974','BLANCA YAMILE','CORTES FARIAS','yamilecortes89@gmail.com','3506089341',NULL,5,49,2,'2018-10-29',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(9,NULL,2,'65755242','ARGENIS','TORRES','argenis15072@gmail.com','3105858599',NULL,5,8,2,'2021-02-11',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(10,NULL,2,'74361270','JOSE ABELINO','MORENO NIÑO','joseabelinomoreno1984@gmail.com','3176441291',NULL,6,8,2,'2021-10-21',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(11,NULL,2,'4136934','JORGE ELIECER','MARCA RIVAS','jorgemarca1974@gmail.com','3219281537',NULL,5,8,2,'2021-12-20',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(12,NULL,2,'1075681541','DAYANA YURLEY','SANTAFE CUBILLOS','dsantafecub06@gmail.com','3008385112',NULL,2,46,2,'2022-05-01',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(13,NULL,2,'1014314696','GABRIEL DAVID','RODRIGUEZ BRICEÑO','rodriguezgabriel809@gmail.com','3114123134',NULL,6,52,2,'2022-07-25',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(14,NULL,2,'20493946','AURORA','RODRIGUEZ PRIETO','roaaurisprieto@gmail.com','3118239952',NULL,5,8,2,'2022-08-03',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(15,NULL,2,'1000472794','ALEJANDRA','CARDENAS MORA','cardenasaleja89@gmail.com','3144511807',NULL,2,47,2,'2023-01-16',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(16,NULL,2,'1054989849','DIANA CAROLINA','RIVERA HERRERA','krorh0227@gmail.com','3225177647',NULL,5,8,2,'2023-08-01',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(17,NULL,2,'91133937','LUIS JAIME','DIAZ AGUILAR','jd6865293@gmail.com','3114835332',NULL,5,8,3,'2023-10-16',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(18,NULL,2,'3029123','CARLOS HUMBERTO','GONZALES RODRIGUEZ','hunbergonsa123@gmail.com','3133522163',NULL,6,8,3,'2023-12-16',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(19,NULL,2,'6910587','NELSON','BAUTISTA ACOSTA','bautistanelson230@gmail.com',NULL,NULL,5,8,3,'2024-01-16',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(20,NULL,2,'94000041','LUIS ELIECER','LOZANO HERNANDEZ','lozanoluiseliecer@gmail.com','3224324805',NULL,5,8,3,'2024-01-16',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(21,NULL,2,'3210268','RICARDO ISIDRO','PINILLA','ricardopinilla245@gmail.com','3227506003',NULL,5,8,3,'2024-02-16',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(22,NULL,2,'1047242344','JHAYNU FAYRUTH','CASTAÑEDA','jhaynujosue03@gmail.com','3115264487',NULL,6,8,3,'2024-02-16',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(23,NULL,2,'20910638','MARTHA ESPERANZA','CASTELBLANCO PULIDO','marthacastelblanco242@gmail.com','3106189598',NULL,6,8,3,'2024-03-01',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(24,NULL,2,'92553179','ROGER RAFAEL','JARABA VIDES','rogerrafaeljaraba@gmail.com','3124313810',NULL,5,8,3,'2024-05-16',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(25,NULL,2,'20577379','SANDRA PATRICIA','ROZO QUINTERO','sandrapatriciarozoquintero@gmail.com','3224361382',NULL,5,8,3,'2024-05-16',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(26,NULL,2,'1075295053','KARLA MARYORI','MARTINEZ SANTOS','karlamaryorimartinez@gmail.com','3215720020',NULL,5,8,3,'2024-05-16',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(27,NULL,2,'1077090167','JUAN MANUEL','CRISTANCHO GONZALEZ',NULL,'3124161264',NULL,6,8,3,'2024-06-01',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(28,NULL,2,'1003650850','ANDRES FELIPE','HERNANDEZ PEÑA','andresfelipehernandezpena105@gmail.com','3134456910',NULL,5,8,3,'2024-06-01',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(29,NULL,2,'1073532736','CESAR ALBERTO','BORQUEZ ROJAS','borquezcesar11@gmail.com','3222454452',NULL,5,8,3,'2024-06-01',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(30,NULL,2,'1073533954','WINDY XIMENA','MORA PINZON','winniximena3@gmail.com','3144479301',NULL,6,8,3,'2024-06-01',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(31,NULL,8,'6246846','EFRAIN JOSE','BENAVIDEZ SOTO','efrainjosebenavidessoto@gmail.com','3118443935',NULL,6,8,3,'2024-06-01',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(32,NULL,8,'7232082','JOSE MIGUEL','BENAVIDEZ SOTO','josemiguelbenavidessoto817@gmail.com','3113518891',NULL,6,8,3,'2024-06-01',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(33,NULL,2,'35415145','SUSANA','FONSECA FONSECA','susanitafonsecafonseca@gmail.com','3057048409',NULL,5,8,3,'2024-08-01',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(34,NULL,2,'1085292843','DEYSI MARISOL','CURAN BOTINA','deysibotina0@gmail.com','3219693370',NULL,5,8,3,'2024-08-01',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(35,NULL,2,'1056954966','GLORIA ESPERANZA','PARRA IBAÑEZ','gloriaeparra123@gmail.com','3163106972',NULL,5,8,3,'2024-08-16',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(36,NULL,2,'1108930775','VILMA MAGALLY','MENDOZA CORTES','mm2718038@gmail.com','3202902591',NULL,6,8,3,'2024-08-16',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(37,NULL,2,'1067970567','IVISMAR LEOMARLIS','ALTAMIRANDA INFANTE','ivismaraltamiranda256@gmail.com','3016720874',NULL,6,8,3,'2024-09-07',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(38,NULL,2,'3028831','FREDY FERNANDO','USMA CARDONA','fredyusma.18@gmail.com','3142135304',NULL,5,8,3,'2024-10-16',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(39,NULL,2,'1075676051','ANGIE MARLEY','VILLARRAGA GOMEZ','angieflkit@hotmail.com','3232819686',NULL,2,12,3,'2024-11-01',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(40,NULL,2,'1056954807','SOLMA ROCIO','FORIGUA MORENO','sforiguamoreno@gmail.com','322338021',NULL,6,8,3,'2024-12-04',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(41,NULL,2,'11522357','JOSE MAURICIO','PEREZ','m4uroperez05@gmail.com','3203701283',NULL,5,8,3,'2025-02-01',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(42,NULL,2,'80395846','FABIO','VANEGAS TEJERO','everlondoovillegas@gmail.com','3228198374',NULL,5,8,3,'2025-02-01',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(43,NULL,2,'9536006','ALIRIO','CASALLAS RODRIGUEZ','aliriocasallas2@gmail.com','3053690261',NULL,5,8,3,'2025-03-03',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(44,NULL,2,'1010254937','YOHANDRY ALBERTO','RUIZ MONTIEL','yohandry.ruiz.230819@gmail.com','3113623537',NULL,6,8,3,'2025-03-16',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(45,NULL,2,'13560825','JOSE LUIS','CARDENAS SANABRIA','dilanjosecardenas0@gmail.com','3143926670',NULL,6,8,3,'2025-08-19',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(46,NULL,2,'39671328','ROSAURA','LOPEZ ZANGUÑA','rosauralopez516@gmail.com','3128166246',NULL,5,8,3,'2025-08-28',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(47,NULL,2,'80540188','OSCAR ALIRIO','VILLARRAGA RODRIGUEZ','aliriovillarraga2019@gmail.com','3133429572',NULL,2,43,3,'2025-09-01',NULL,'ACTIVO','no aplica',0,NULL,'2026-08-11 10:41:26',NULL),(48,NULL,2,'24219232','ANA DORIS','MUÑOZ CONTRERAS','amapolamunos@gmail.com','3013224890',NULL,5,8,3,'2025-08-28',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(49,NULL,2,'1071142685','DIANA ROCIO','VELANDIA RODRIGUEZ','velandiad024@gmail.com','3224326070',NULL,5,8,3,'2025-09-29',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(50,NULL,2,'64894338','MARICELA DEL CARMEN','DIAZ MONTES','mariceladiaz0755@gmail.com','3132818317',NULL,5,8,3,'2025-10-02',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(51,NULL,2,'11410639','JOAQUIN','MORENO HUERFANO','joaquinmorenohuerfano@gmail.com','3125913053',NULL,5,8,3,'2025-10-27',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(52,NULL,2,'1013629581','EVELIN YISEL','PICHINA VERA','yacumapalomasamantha@gmail.com','3043110256',NULL,5,8,3,'2025-10-27',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(53,NULL,2,'1006582387','EIKIR JAVIER','SIERRA RODRIGUEZ','eiker4780@gmail.com','3006435200',NULL,6,8,3,'2025-11-26',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(54,NULL,2,'1042472736','JOHANDRY ANTONIO','AVILA AVILA','johandryavila172@gmail.com','3108752858',NULL,6,8,3,'2025-11-16',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(55,NULL,2,'1045436852','SANTIAGO','JIMENEZ GARCIA','jimenezgarciasantiago89@gmail.com','3222350897',NULL,5,8,3,'2025-12-05',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(56,NULL,2,'1102896865','JORGE LUIS','OVIEDO TORRES','jorgeoviedo892@gmail.com','3144004831',NULL,5,8,3,'2025-12-10',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(57,NULL,2,'3212639','LUIS ANTONIO','RODRIGUEZ QUINTERO','nuriteamo1705@gmail.com','3204145773',NULL,5,8,3,'2025-12-10',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(58,NULL,8,'6194015','MARIANGEL DEL CARMEN','FERNANDEZ FERNANDEZ','fernandezfernandezmariaangel@gmail.com','3134148183',NULL,5,8,3,'2025-12-18',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(59,NULL,2,'1007191488','JHON ALEXANDER','FLOREZ SANCHEZ','sanchezjhon24061996@gmail.com','3223103780',NULL,5,8,3,'2025-12-19',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(60,NULL,2,'52602786','NELI CONSUELO','LEIVA','riveraleivaneliconsuelo@gmail.com','3103628377',NULL,6,8,3,'2026-01-02',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(61,NULL,2,'1002498743','ZABALETA DAVILA','FRANCK DAVID','alisdawila486@gmail.com','3137289283',NULL,6,8,3,'2026-01-05',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(62,NULL,2,'92671784','FRAIBER','SOLANO PEÑA','fraibersolano@gmail.com',NULL,NULL,6,8,3,'2026-02-01',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(63,NULL,2,'1007651906','BLANCA NURY','TAPASCO ARICAPA','nuriteamo1705@gmail.com','3112803057',NULL,5,8,3,'2026-02-09',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(64,NULL,2,'1102870929','BRAYAN JOSUE','AVILA MACHADO','brayannavila22.2@gmail.com','3108752858',NULL,6,8,3,'2026-02-17',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(65,NULL,2,'73232117','LEOVANI','BUELVAS ORTEGA','leovanibuelvas@gmail.com','3229130214',NULL,6,8,3,'2026-03-09',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(66,NULL,2,'20977059','DIANA MARIA','SUTA MORA','dianamariasuta@gmail.com','3213858345',NULL,6,45,3,'2026-03-09',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(67,NULL,2,'1006121518','MAIKOL STIVEN','CASTILLO PALACIOS','castillomaikol337@gmail.com','3209052676',NULL,5,8,3,'2026-03-20',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(68,NULL,2,'1072253947','BREIDIS','ESPAÑA SIERRA','breidisespana1986@gmail.com','3123972608',NULL,5,8,3,'2026-03-20',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(69,NULL,2,'80931979','CESAR ANDRES','HERNANDEZ NIÑO','cesarandres.hernandez@uptc.edu.co','3142636109',NULL,5,8,3,'2026-04-08',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(70,NULL,2,'1071941147','MARIANA','RAMIREZ VANEGAS','mari007rv@gmail.com','3118033112',NULL,2,50,3,'2026-04-01',NULL,'ACTIVO','electiva',0,NULL,'2026-08-11 10:41:26',NULL),(71,NULL,2,'1048067278','HOINER MANUEL','JULIO SOLANO','juliohoiner@gmail.com','3212514867',NULL,5,8,3,'2026-04-13',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(72,NULL,2,'1003704683','KAREN JULIETH','GACHETA QUINTERO','julieth.gacheta18@gmail.com','3222435335',NULL,6,8,3,'2026-05-01',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(73,NULL,2,'20493922','IVETH PALOMA','BENAVIDES NAVARRETE','ivethbenavides@gmail.com','3204591050',NULL,6,8,3,'2026-05-01',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(74,NULL,2,'3029060','WILLIAM ANDRES','CORTES SARMIENTO','riveraleivaneliconsuelo@gmail.com',NULL,NULL,5,48,3,'2026-05-19',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(75,NULL,2,'1032512995','DIANETH AURORA','GONZALEZ MENDIVIL','dianethmendivil0805@gmail.om','3133035749',NULL,6,8,3,'2026-05-20',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(76,NULL,2,'1126427126','CIRO ENMANUEL','BECERRA SALCEDO','ciroenmanuelbs@gmail.com','3124022185 (whatsapp) / 321922773',NULL,5,8,3,'2026-05-22',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(77,NULL,2,'1123531021','YULIANA MAYERLY','GALINDO ROZO','rozoyuliana04@gmail.com','3128909629',NULL,5,8,3,'2026-06-03',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL),(78,NULL,2,'1073533365','FRANCY YAMILE','SUAREZ SANTOS','suarezsantosfrancyyamile@gmail.com',NULL,NULL,5,8,3,'2026-06-20',NULL,'ACTIVO',NULL,0,NULL,'2026-08-11 10:41:26',NULL);
/*!40000 ALTER TABLE `bbf_empleados` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_entidades_seguridad_social`
--

DROP TABLE IF EXISTS `bbf_entidades_seguridad_social`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_entidades_seguridad_social` (
  `ID_ENTIDAD_SEGURIDAD_SOCIAL` int(11) NOT NULL AUTO_INCREMENT,
  `TIPO_ENTIDAD` enum('EPS','ARL','PENSION','CESANTIAS','CAJA_COMPENSACION') NOT NULL,
  `NOMBRE` varchar(150) NOT NULL,
  `NIT` varchar(50) DEFAULT NULL,
  `ACTIVO` tinyint(1) NOT NULL DEFAULT 1,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_ENTIDAD_SEGURIDAD_SOCIAL`),
  UNIQUE KEY `UQ_BBF_ENTIDAD_SEG_SOCIAL` (`TIPO_ENTIDAD`,`NOMBRE`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_entidades_seguridad_social`
--

LOCK TABLES `bbf_entidades_seguridad_social` WRITE;
/*!40000 ALTER TABLE `bbf_entidades_seguridad_social` DISABLE KEYS */;
INSERT INTO `bbf_entidades_seguridad_social` VALUES (1,'EPS','Nueva EPS',NULL,1,'2026-06-23 22:40:44',NULL),(2,'EPS','Sura EPS',NULL,1,'2026-06-23 22:40:44',NULL),(3,'EPS','Sanitas EPS',NULL,1,'2026-06-23 22:40:44',NULL),(4,'EPS','Compensar EPS',NULL,1,'2026-06-23 22:40:44',NULL),(5,'EPS','Famisanar EPS',NULL,1,'2026-06-23 22:40:44',NULL),(6,'EPS','Coosalud EPS',NULL,1,'2026-06-23 22:40:44',NULL),(7,'ARL','ARL Sura',NULL,1,'2026-06-23 22:40:44',NULL),(8,'ARL','ARL Positiva',NULL,1,'2026-06-23 22:40:44',NULL),(9,'ARL','ARL Colmena',NULL,1,'2026-06-23 22:40:44',NULL),(10,'ARL','ARL AXA Colpatria',NULL,1,'2026-06-23 22:40:44',NULL),(11,'PENSION','Porvenir',NULL,1,'2026-06-23 22:40:44',NULL),(12,'PENSION','Protección',NULL,1,'2026-06-23 22:40:44',NULL),(13,'PENSION','Colpensiones',NULL,1,'2026-06-23 22:40:44',NULL),(14,'PENSION','Skandia',NULL,1,'2026-06-23 22:40:44',NULL),(15,'CESANTIAS','Porvenir Cesantías',NULL,1,'2026-06-23 22:40:44',NULL),(16,'CESANTIAS','Protección Cesantías',NULL,1,'2026-06-23 22:40:44',NULL),(17,'CESANTIAS','Fondo Nacional del Ahorro',NULL,1,'2026-06-23 22:40:44',NULL),(18,'CAJA_COMPENSACION','Comfenalco Valle',NULL,1,'2026-06-23 22:40:44',NULL),(19,'CAJA_COMPENSACION','Comfandi',NULL,1,'2026-06-23 22:40:44',NULL),(20,'CAJA_COMPENSACION','Compensar',NULL,1,'2026-06-23 22:40:44',NULL),(21,'CAJA_COMPENSACION','Cafam',NULL,1,'2026-06-23 22:40:44',NULL),(32,'EPS','Aliansalud EPS',NULL,1,'2026-08-10 10:51:14',NULL),(33,'EPS','Mutual Ser EPS',NULL,1,'2026-08-10 10:51:14',NULL),(34,'EPS','Salud Total EPS',NULL,1,'2026-08-10 10:51:14',NULL),(35,'PENSION','Colfondos',NULL,1,'2026-08-10 10:51:14',NULL),(36,'CAJA_COMPENSACION','Colsubsidio',NULL,1,'2026-08-10 10:51:14',NULL);
/*!40000 ALTER TABLE `bbf_entidades_seguridad_social` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_herramientas`
--

DROP TABLE IF EXISTS `bbf_herramientas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_herramientas` (
  `id_herramienta` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(150) NOT NULL,
  `descripcion` varchar(500) DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`id_herramienta`),
  UNIQUE KEY `uq_bbf_herramientas_nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=87 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_herramientas`
--

LOCK TABLES `bbf_herramientas` WRITE;
/*!40000 ALTER TABLE `bbf_herramientas` DISABLE KEYS */;
INSERT INTO `bbf_herramientas` VALUES (1,'Casco de seguridad',NULL,1,'2026-07-27 12:37:01',NULL),(2,'Gafas de seguridad transparentes',NULL,1,'2026-07-27 12:37:01',NULL),(3,'Gafas oscuras con filtro UV',NULL,1,'2026-07-27 12:37:01',NULL),(4,'Monogafas para aplicación de agroquímicos',NULL,1,'2026-07-27 12:37:01',NULL),(5,'Protección respiratoria',NULL,1,'2026-07-27 12:37:01',NULL),(6,'Respirador media cara',NULL,1,'2026-07-27 12:37:01',NULL),(7,'Respirador de cara completa',NULL,1,'2026-07-27 12:37:01',NULL),(8,'Mascarillas desechables N95',NULL,1,'2026-07-27 12:37:01',NULL),(9,'Filtros para vapores orgánicos',NULL,1,'2026-07-27 12:37:01',NULL),(10,'Prefiltros para partículas',NULL,1,'2026-07-27 12:37:01',NULL),(11,'Protección auditiva copa',NULL,1,'2026-07-27 12:37:01',NULL),(12,'Tapones auditivos',NULL,1,'2026-07-27 12:37:01',NULL),(13,'Guantes de nitrilo',NULL,1,'2026-07-27 12:37:01',NULL),(14,'Guantes de látex',NULL,1,'2026-07-27 12:37:01',NULL),(15,'Guantes de carnaza',NULL,1,'2026-07-27 12:37:01',NULL),(16,'Guantes impermeables para fumigación Protex calibre 55',NULL,1,'2026-07-27 12:37:01',NULL),(17,'Overoles antifluidos',NULL,1,'2026-07-27 12:37:01',NULL),(18,'Overoles para fumigación',NULL,1,'2026-07-27 12:37:01',NULL),(19,'Delantales impermeables',NULL,1,'2026-07-27 12:37:01',NULL),(20,'Chalecos reflectivos',NULL,1,'2026-07-27 12:37:01',NULL),(21,'Impermeables para riego',NULL,1,'2026-07-27 12:37:01',NULL),(22,'Botas de seguridad dieléctricas',NULL,1,'2026-07-27 12:37:01',NULL),(23,'Botas de caucho',NULL,1,'2026-07-27 12:37:01',NULL),(24,'Botas de cuero liso',NULL,1,'2026-07-27 12:37:01',NULL),(25,'Líneas de vida',NULL,1,'2026-07-27 12:37:01',NULL),(26,'Chalecos salvavidas',NULL,1,'2026-07-27 12:37:01',NULL),(27,'Donas salvavidas',NULL,1,'2026-07-27 12:37:01',NULL),(28,'Tijeras Felco 300',NULL,1,'2026-07-27 12:37:01',NULL),(29,'Tijeras de palo seco',NULL,1,'2026-07-27 12:37:01',NULL),(30,'Desbotonadoras',NULL,1,'2026-07-27 12:37:01',NULL),(31,'Carros de corte',NULL,1,'2026-07-27 12:37:01',NULL),(32,'Medidores de pH',NULL,1,'2026-07-27 12:37:01',NULL),(33,'Medidores de conductividad eléctrica (CE)',NULL,1,'2026-07-27 12:37:01',NULL),(34,'Termómetros',NULL,1,'2026-07-27 12:37:01',NULL),(35,'Higrómetros',NULL,1,'2026-07-27 12:37:01',NULL),(36,'Pulverizadores manuales',NULL,1,'2026-07-27 12:37:01',NULL),(37,'Bombas de espalda',NULL,1,'2026-07-27 12:37:01',NULL),(38,'Mallas capuchón',NULL,1,'2026-07-27 12:37:01',NULL),(39,'Tensores',NULL,1,'2026-07-27 12:37:01',NULL),(40,'Grapadoras B8',NULL,1,'2026-07-27 12:37:01',NULL),(41,'Palas redondas',NULL,1,'2026-07-27 12:37:01',NULL),(42,'Palas cuadradas',NULL,1,'2026-07-27 12:37:01',NULL),(43,'Palines',NULL,1,'2026-07-27 12:37:01',NULL),(44,'Picas',NULL,1,'2026-07-27 12:37:01',NULL),(45,'Azadones',NULL,1,'2026-07-27 12:37:01',NULL),(46,'Rastrillos',NULL,1,'2026-07-27 12:37:01',NULL),(47,'Barras',NULL,1,'2026-07-27 12:37:01',NULL),(48,'Machetes',NULL,1,'2026-07-27 12:37:01',NULL),(49,'Hachas',NULL,1,'2026-07-27 12:37:01',NULL),(50,'Serruchos de poda',NULL,1,'2026-07-27 12:37:01',NULL),(51,'Tijeras de poda',NULL,1,'2026-07-27 12:37:01',NULL),(52,'Martillos',NULL,1,'2026-07-27 12:37:01',NULL),(53,'Mazos de caucho',NULL,1,'2026-07-27 12:37:01',NULL),(54,'Alicates',NULL,1,'2026-07-27 12:37:01',NULL),(55,'Pinzas universales',NULL,1,'2026-07-27 12:37:01',NULL),(56,'Llaves ajustables (expansivas)',NULL,1,'2026-07-27 12:37:01',NULL),(57,'Juegos de llaves fijas y combinadas',NULL,1,'2026-07-27 12:37:01',NULL),(58,'Juegos de llaves Allen',NULL,1,'2026-07-27 12:37:01',NULL),(59,'Destornilladores planos',NULL,1,'2026-07-27 12:37:01',NULL),(60,'Destornilladores de estrella',NULL,1,'2026-07-27 12:37:01',NULL),(61,'Cintas métricas',NULL,1,'2026-07-27 12:37:01',NULL),(62,'Flexómetros',NULL,1,'2026-07-27 12:37:01',NULL),(63,'Niveles',NULL,1,'2026-07-27 12:37:01',NULL),(64,'Escuadras',NULL,1,'2026-07-27 12:37:01',NULL),(65,'Linternas',NULL,1,'2026-07-27 12:37:01',NULL),(66,'Taladro eléctrico',NULL,1,'2026-07-27 12:37:01',NULL),(67,'Taladro inalámbrico',NULL,1,'2026-07-27 12:37:01',NULL),(68,'Esmeril angular',NULL,1,'2026-07-27 12:37:01',NULL),(69,'Pistola de silicona',NULL,1,'2026-07-27 12:37:01',NULL),(70,'Remachadora',NULL,1,'2026-07-27 12:37:01',NULL),(71,'Llave de tubo',NULL,1,'2026-07-27 12:37:01',NULL),(72,'Llave Stilson',NULL,1,'2026-07-27 12:37:01',NULL),(73,'Juego de dados',NULL,1,'2026-07-27 12:37:01',NULL),(74,'Multímetro',NULL,1,'2026-07-27 12:37:01',NULL),(75,'Pelacables',NULL,1,'2026-07-27 12:37:01',NULL),(76,'Probador de corriente',NULL,1,'2026-07-27 12:37:01',NULL),(77,'Llaves para hidrantes',NULL,1,'2026-07-27 12:37:01',NULL),(78,'Llaves de paso',NULL,1,'2026-07-27 12:37:01',NULL),(79,'Cortatubos PVC',NULL,1,'2026-07-27 12:37:01',NULL),(80,'Pegante PVC',NULL,1,'2026-07-27 12:37:01',NULL),(81,'Sierra para PVC',NULL,1,'2026-07-27 12:37:01',NULL),(82,'Perforadores para manguera',NULL,1,'2026-07-27 12:37:01',NULL),(83,'Sacabocados',NULL,1,'2026-07-27 12:37:01',NULL),(84,'Destapadores de goteros',NULL,1,'2026-07-27 12:37:01',NULL),(85,'Escaleras de aluminio',NULL,1,'2026-07-27 12:37:01',NULL);
/*!40000 ALTER TABLE `bbf_herramientas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_herramientas_entrega_detalle`
--

DROP TABLE IF EXISTS `bbf_herramientas_entrega_detalle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_herramientas_entrega_detalle` (
  `id_detalle` int(11) NOT NULL AUTO_INCREMENT,
  `id_entrega` int(11) NOT NULL,
  `id_herramienta` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL DEFAULT 1,
  `observaciones` varchar(500) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`id_detalle`),
  UNIQUE KEY `uq_bbf_herramientas_detalle_entrega_herramienta` (`id_entrega`,`id_herramienta`),
  KEY `idx_bbf_herramientas_detalle_entrega` (`id_entrega`),
  KEY `idx_bbf_herramientas_detalle_herramienta` (`id_herramienta`),
  CONSTRAINT `fk_bbf_herramientas_detalle_entrega` FOREIGN KEY (`id_entrega`) REFERENCES `bbf_herramientas_entregas` (`id_entrega`),
  CONSTRAINT `fk_bbf_herramientas_detalle_herramienta` FOREIGN KEY (`id_herramienta`) REFERENCES `bbf_herramientas` (`id_herramienta`),
  CONSTRAINT `chk_bbf_herramientas_detalle_cantidad` CHECK (`cantidad` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_herramientas_entrega_detalle`
--

LOCK TABLES `bbf_herramientas_entrega_detalle` WRITE;
/*!40000 ALTER TABLE `bbf_herramientas_entrega_detalle` DISABLE KEYS */;
/*!40000 ALTER TABLE `bbf_herramientas_entrega_detalle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_herramientas_entrega_evidencias`
--

DROP TABLE IF EXISTS `bbf_herramientas_entrega_evidencias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_herramientas_entrega_evidencias` (
  `id_evidencia` int(11) NOT NULL AUTO_INCREMENT,
  `id_entrega` int(11) NOT NULL,
  `nombre_archivo` varchar(255) NOT NULL,
  `nombre_original` varchar(255) DEFAULT NULL,
  `archivo_url` varchar(500) DEFAULT NULL,
  `archivo_ruta` varchar(500) DEFAULT NULL,
  `mime_type` varchar(100) NOT NULL,
  `peso_bytes` bigint(20) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_evidencia`),
  KEY `idx_bbf_herr_ent_evid_entrega` (`id_entrega`),
  CONSTRAINT `fk_bbf_herr_ent_evid_entrega` FOREIGN KEY (`id_entrega`) REFERENCES `bbf_herramientas_entregas` (`id_entrega`) ON DELETE CASCADE,
  CONSTRAINT `chk_bbf_herr_ent_evid_ubicacion` CHECK (`archivo_url` is not null and trim(`archivo_url`) <> '' and (`archivo_ruta` is null or trim(`archivo_ruta`) = '') or `archivo_ruta` is not null and trim(`archivo_ruta`) <> '' and (`archivo_url` is null or trim(`archivo_url`) = '')),
  CONSTRAINT `chk_bbf_herr_ent_evid_peso` CHECK (`peso_bytes` is null or `peso_bytes` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_herramientas_entrega_evidencias`
--

LOCK TABLES `bbf_herramientas_entrega_evidencias` WRITE;
/*!40000 ALTER TABLE `bbf_herramientas_entrega_evidencias` DISABLE KEYS */;
/*!40000 ALTER TABLE `bbf_herramientas_entrega_evidencias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_herramientas_entregas`
--

DROP TABLE IF EXISTS `bbf_herramientas_entregas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_herramientas_entregas` (
  `id_entrega` int(11) NOT NULL AUTO_INCREMENT,
  `id_empleado` int(11) NOT NULL,
  `fecha_entrega` date NOT NULL,
  `estado` enum('pendiente','confirmada') NOT NULL DEFAULT 'pendiente',
  `observaciones` text DEFAULT NULL,
  `fecha_confirmacion` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`id_entrega`),
  KEY `idx_bbf_herramientas_entregas_empleado` (`id_empleado`),
  KEY `idx_bbf_herramientas_entregas_fecha` (`fecha_entrega`),
  KEY `idx_bbf_herramientas_entregas_estado` (`estado`),
  CONSTRAINT `fk_bbf_herramientas_entregas_empleado` FOREIGN KEY (`id_empleado`) REFERENCES `bbf_empleados` (`ID_EMPLEADO`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_herramientas_entregas`
--

LOCK TABLES `bbf_herramientas_entregas` WRITE;
/*!40000 ALTER TABLE `bbf_herramientas_entregas` DISABLE KEYS */;
/*!40000 ALTER TABLE `bbf_herramientas_entregas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_log_auditoria`
--

DROP TABLE IF EXISTS `bbf_log_auditoria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_log_auditoria` (
  `ID_LOG` bigint(20) NOT NULL AUTO_INCREMENT,
  `ID_USUARIO` int(11) DEFAULT NULL,
  `MODULO` varchar(100) NOT NULL,
  `ACCION` varchar(100) NOT NULL,
  `ENTIDAD` varchar(100) DEFAULT NULL,
  `ENTIDAD_ID` int(11) DEFAULT NULL,
  `DATOS_ANTERIORES` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`DATOS_ANTERIORES`)),
  `DATOS_NUEVOS` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`DATOS_NUEVOS`)),
  `IP_ORIGEN` varchar(50) DEFAULT NULL,
  `USER_AGENT` varchar(500) DEFAULT NULL,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`ID_LOG`),
  KEY `FK_BBF_LOG_AUDITORIA_USUARIO` (`ID_USUARIO`),
  CONSTRAINT `FK_BBF_LOG_AUDITORIA_USUARIO` FOREIGN KEY (`ID_USUARIO`) REFERENCES `bbf_usuarios` (`ID_USUARIO`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_log_auditoria`
--

LOCK TABLES `bbf_log_auditoria` WRITE;
/*!40000 ALTER TABLE `bbf_log_auditoria` DISABLE KEYS */;
INSERT INTO `bbf_log_auditoria` VALUES (2,15,'EMPLEADOS','CARGA_MASIVA_IMPORTAR','CARGA_MASIVA',NULL,NULL,'{\"cantidad_creada\":76,\"archivo\":\"base de  pagina.xlsx\",\"resultado\":\"EXITOSO\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-11 10:41:26'),(3,15,'EMPLEADOS','ACTUALIZAR','EMPLEADO',3,'{\"id_empleado\":3,\"id_tipo_documento\":2,\"tipo_documento\":\"Cédula de ciudadanía\",\"numero_documento\":\"1075661055\",\"nombres\":\"YULIANA LICETTE\",\"apellidos\":\"VILLARRAGA GOMEZ\",\"nombre_completo\":\"YULIANA LICETTE VILLARRAGA GOMEZ\",\"correo\":\"barroblancofarms@gmail.com\",\"telefono\":\"3142473591\",\"foto_url\":null,\"id_area\":2,\"area\":\"Administración\",\"id_cargo\":44,\"cargo\":\"Gerente general\",\"id_tipo_contrato\":2,\"tipo_contrato\":\"Indefinido\",\"fecha_ingreso\":\"2015-02-01\",\"fecha_retiro\":null,\"estado_empleado\":\"ACTIVO\",\"observaciones\":null,\"created_at\":\"2026-08-11 10:41:26\",\"updated_at\":null}','{\"id_empleado\":3,\"id_tipo_documento\":2,\"tipo_documento\":\"Cédula de ciudadanía\",\"numero_documento\":\"1075661055\",\"nombres\":\"YULIANA LICETTE\",\"apellidos\":\"VILLARRAGA GOMEZ\",\"nombre_completo\":\"YULIANA LICETTE VILLARRAGA GOMEZ\",\"correo\":\"barroblancofarms@gmail.com\",\"telefono\":\"3142473591\",\"foto_url\":null,\"id_area\":2,\"area\":\"Administración\",\"id_cargo\":44,\"cargo\":\"Gerente general\",\"id_tipo_contrato\":2,\"tipo_contrato\":\"Indefinido\",\"fecha_ingreso\":\"2015-02-01\",\"fecha_retiro\":null,\"estado_empleado\":\"ACTIVO\",\"observaciones\":null,\"created_at\":\"2026-08-11 10:41:26\",\"updated_at\":null}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-11 10:41:41'),(4,15,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',15,NULL,'{\"correo\":\"AD@Email.com\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-11 10:52:40'),(5,15,'CAPACITACIONES','SESION_CREAR','CAPACITACION',NULL,NULL,'{\"id_capacitacion_sesion\":1,\"id_capacitacion\":2,\"codigo\":\"CAP-2-202631-0801\",\"fecha_inicio\":\"2026-08-01\",\"fecha_fin\":\"2026-08-08\",\"anio_iso\":2026,\"semana_iso\":31,\"id_instructor_usuario\":null,\"instructor_externo\":\"Pepito\",\"lugar\":\"local\",\"estado\":\"BORRADOR\",\"observaciones\":\"na\",\"fecha_cierre\":null,\"id_creado_por\":15,\"id_cerrado_por\":null,\"created_at\":\"2026-08-11 10:53:09\",\"updated_at\":null}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-11 10:53:09'),(6,15,'CAPACITACIONES','SESION_CREAR','CAPACITACION',NULL,NULL,'{\"id_capacitacion_sesion\":2,\"id_capacitacion\":2,\"codigo\":\"CAP-2-202632-0809\",\"fecha_inicio\":\"2026-08-09\",\"fecha_fin\":\"2026-08-15\",\"anio_iso\":2026,\"semana_iso\":32,\"id_instructor_usuario\":null,\"instructor_externo\":\"Pepito\",\"lugar\":\"local\",\"estado\":\"BORRADOR\",\"observaciones\":\"na\",\"fecha_cierre\":null,\"id_creado_por\":15,\"id_cerrado_por\":null,\"created_at\":\"2026-08-11 10:53:28\",\"updated_at\":null}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-11 10:53:28'),(7,15,'CAPACITACIONES','PARTICIPANTE_AGREGAR','CAPACITACION',NULL,NULL,'{\"id_capacitacion_participante\":1,\"id_capacitacion_sesion\":1,\"id_empleado\":3,\"estado_asistencia\":\"PENDIENTE\",\"confirmo_recibido\":0,\"fecha_confirmacion\":null,\"id_confirmado_por\":null,\"modalidad_confirmacion\":null,\"observacion_confirmacion\":null,\"estado_evaluacion\":\"PENDIENTE\",\"observaciones\":null,\"id_registrado_por\":15,\"created_at\":\"2026-08-11 10:53:35\",\"updated_at\":null}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-11 10:53:35'),(8,15,'CAPACITACIONES','PARTICIPANTE_AGREGAR','CAPACITACION',NULL,NULL,'{\"id_capacitacion_participante\":2,\"id_capacitacion_sesion\":2,\"id_empleado\":3,\"estado_asistencia\":\"PENDIENTE\",\"confirmo_recibido\":0,\"fecha_confirmacion\":null,\"id_confirmado_por\":null,\"modalidad_confirmacion\":null,\"observacion_confirmacion\":null,\"estado_evaluacion\":\"PENDIENTE\",\"observaciones\":null,\"id_registrado_por\":15,\"created_at\":\"2026-08-11 10:53:47\",\"updated_at\":null}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-11 10:53:47'),(9,15,'CAPACITACIONES','PARTICIPANTE_AGREGAR','CAPACITACION',NULL,NULL,'{\"id_capacitacion_participante\":3,\"id_capacitacion_sesion\":2,\"id_empleado\":4,\"estado_asistencia\":\"PENDIENTE\",\"confirmo_recibido\":0,\"fecha_confirmacion\":null,\"id_confirmado_por\":null,\"modalidad_confirmacion\":null,\"observacion_confirmacion\":null,\"estado_evaluacion\":\"PENDIENTE\",\"observaciones\":null,\"id_registrado_por\":15,\"created_at\":\"2026-08-11 10:59:11\",\"updated_at\":null}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-11 10:59:11'),(10,15,'CAPACITACIONES','RESULTADO_REGISTRAR','CAPACITACION',NULL,NULL,'{\"id_capacitacion_resultado\":1,\"id_capacitacion_participante\":3,\"fecha_resultado\":\"2026-08-11\",\"total_acumulado\":\"0.00\",\"puntaje_final\":\"2.00\",\"puntaje_minimo_aplicado\":null,\"resultado\":\"PENDIENTE\",\"requiere_reinduccion\":0,\"requiere_compromiso\":0,\"regla_aplicada\":null,\"observaciones\":null,\"id_registrado_por\":15,\"created_at\":\"2026-08-11 10:59:28\",\"updated_at\":null}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-11 10:59:28'),(11,15,'CAPACITACIONES','RESULTADO_REGISTRAR','CAPACITACION',NULL,NULL,'{\"id_capacitacion_resultado\":1,\"id_capacitacion_participante\":3,\"fecha_resultado\":\"2026-08-11\",\"total_acumulado\":\"0.00\",\"puntaje_final\":\"2.00\",\"puntaje_minimo_aplicado\":null,\"resultado\":\"NO_APROBADO\",\"requiere_reinduccion\":0,\"requiere_compromiso\":0,\"regla_aplicada\":null,\"observaciones\":null,\"id_registrado_por\":15,\"created_at\":\"2026-08-11 10:59:28\",\"updated_at\":\"2026-08-11 10:59:56\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-11 10:59:56'),(12,15,'CAPACITACIONES','COMPROMISO_CREAR','CAPACITACION',NULL,NULL,'{\"id_capacitacion_compromiso\":1,\"id_capacitacion_resultado\":1,\"fecha_compromiso\":\"2026-08-11\",\"fecha_limite\":\"2026-08-19\",\"motivo\":\"Resultado NO_APROBADO en la capacitación.\",\"compromisos_empleado\":null,\"estado\":\"BORRADOR\",\"documento_url\":null,\"documento_ruta\":null,\"firma_url\":null,\"fecha_firma\":null,\"observaciones\":null,\"id_creado_por\":15,\"id_cerrado_por\":null,\"created_at\":\"2026-08-11 11:00:06\",\"updated_at\":null}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-11 11:00:06');
/*!40000 ALTER TABLE `bbf_log_auditoria` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_municipios`
--

DROP TABLE IF EXISTS `bbf_municipios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_municipios` (
  `ID_MUNICIPIO` int(11) NOT NULL AUTO_INCREMENT,
  `ID_DEPARTAMENTO` int(11) NOT NULL,
  `CODIGO_DANE` varchar(5) NOT NULL,
  `NOMBRE` varchar(150) NOT NULL,
  `ACTIVO` tinyint(1) NOT NULL DEFAULT 1,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_MUNICIPIO`),
  UNIQUE KEY `UK_BBF_MUNICIPIOS_CODIGO` (`CODIGO_DANE`),
  KEY `IDX_BBF_MUNICIPIOS_DEPARTAMENTO` (`ID_DEPARTAMENTO`),
  KEY `IDX_BBF_MUNICIPIOS_NOMBRE` (`NOMBRE`),
  KEY `IDX_BBF_MUNICIPIOS_ACTIVO` (`ACTIVO`),
  CONSTRAINT `FK_BBF_MUNICIPIOS_DEPARTAMENTO` FOREIGN KEY (`ID_DEPARTAMENTO`) REFERENCES `bbf_departamentos` (`ID_DEPARTAMENTO`)
) ENGINE=InnoDB AUTO_INCREMENT=155 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_municipios`
--

LOCK TABLES `bbf_municipios` WRITE;
/*!40000 ALTER TABLE `bbf_municipios` DISABLE KEYS */;
INSERT INTO `bbf_municipios` VALUES (1,1,'05001','MEDELLÍN',1,'2026-07-23 21:15:56',NULL),(2,1,'05002','ABEJORRAL',1,'2026-07-23 21:15:56',NULL),(3,1,'05004','ABRIAQUÍ',1,'2026-07-23 21:15:56',NULL),(4,1,'05021','ALEJANDRÍA',1,'2026-07-23 21:15:56',NULL),(5,1,'05030','AMAGÁ',1,'2026-07-23 21:15:56',NULL),(6,1,'05031','AMALFI',1,'2026-07-23 21:15:56',NULL),(7,1,'05034','ANDES',1,'2026-07-23 21:15:56',NULL),(8,1,'05036','ANGELÓPOLIS',1,'2026-07-23 21:15:56',NULL),(9,1,'05038','ANGOSTURA',1,'2026-07-23 21:15:56',NULL),(10,1,'05040','ANORÍ',1,'2026-07-23 21:15:56',NULL),(11,1,'05042','SANTA FÉ DE ANTIOQUIA',1,'2026-07-23 21:15:56',NULL),(12,1,'05044','ANZÁ',1,'2026-07-23 21:15:56',NULL),(13,1,'05045','APARTADÓ',1,'2026-07-23 21:15:56',NULL),(14,1,'05051','ARBOLETES',1,'2026-07-23 21:15:56',NULL),(15,1,'05055','ARGELIA',1,'2026-07-23 21:15:56',NULL),(16,1,'05059','ARMENIA',1,'2026-07-23 21:15:56',NULL),(17,1,'05079','BARBOSA',1,'2026-07-23 21:15:56',NULL),(18,1,'05086','BELMIRA',1,'2026-07-23 21:15:56',NULL),(19,1,'05088','BELLO',1,'2026-07-23 21:15:56',NULL),(20,1,'05091','BETANIA',1,'2026-07-23 21:15:56',NULL),(21,1,'05093','BETULIA',1,'2026-07-23 21:15:56',NULL),(22,1,'05101','CIUDAD BOLÍVAR',1,'2026-07-23 21:15:56',NULL),(23,1,'05107','BRICEÑO',1,'2026-07-23 21:15:56',NULL),(24,1,'05113','BURITICÁ',1,'2026-07-23 21:15:56',NULL),(25,1,'05120','CÁCERES',1,'2026-07-23 21:15:56',NULL),(26,1,'05125','CAICEDO',1,'2026-07-23 21:15:56',NULL),(27,1,'05129','CALDAS',1,'2026-07-23 21:15:56',NULL),(28,1,'05134','CAMPAMENTO',1,'2026-07-23 21:15:56',NULL),(29,1,'05138','CAÑASGORDAS',1,'2026-07-23 21:15:56',NULL),(30,1,'05142','CARACOLÍ',1,'2026-07-23 21:15:56',NULL),(31,1,'05145','CARAMANTA',1,'2026-07-23 21:15:56',NULL),(32,1,'05147','CAREPA',1,'2026-07-23 21:15:56',NULL),(33,1,'05148','EL CARMEN DE VIBORAL',1,'2026-07-23 21:15:56',NULL),(34,1,'05150','CAROLINA',1,'2026-07-23 21:15:56',NULL),(35,1,'05154','CAUCASIA',1,'2026-07-23 21:15:56',NULL),(36,1,'05172','CHIGORODÓ',1,'2026-07-23 21:15:56',NULL),(37,1,'05190','CISNEROS',1,'2026-07-23 21:15:56',NULL),(38,1,'05197','COCORNÁ',1,'2026-07-23 21:15:56',NULL),(39,1,'05206','CONCEPCIÓN',1,'2026-07-23 21:15:56',NULL),(40,1,'05209','CONCORDIA',1,'2026-07-23 21:15:56',NULL),(41,1,'05212','COPACABANA',1,'2026-07-23 21:15:56',NULL),(42,1,'05234','DABEIBA',1,'2026-07-23 21:15:56',NULL),(43,1,'05237','DONMATÍAS',1,'2026-07-23 21:15:56',NULL),(44,1,'05240','EBÉJICO',1,'2026-07-23 21:15:56',NULL),(45,1,'05250','EL BAGRE',1,'2026-07-23 21:15:56',NULL),(46,1,'05264','ENTRERRÍOS',1,'2026-07-23 21:15:56',NULL),(47,1,'05266','ENVIGADO',1,'2026-07-23 21:15:56',NULL),(48,1,'05282','FREDONIA',1,'2026-07-23 21:15:56',NULL),(49,1,'05284','FRONTINO',1,'2026-07-23 21:15:56',NULL),(50,1,'05306','GIRALDO',1,'2026-07-23 21:15:56',NULL),(51,1,'05308','GIRARDOTA',1,'2026-07-23 21:15:56',NULL),(52,1,'05310','GÓMEZ PLATA',1,'2026-07-23 21:15:56',NULL),(53,1,'05313','GRANADA',1,'2026-07-23 21:15:56',NULL),(54,1,'05315','GUADALUPE',1,'2026-07-23 21:15:56',NULL),(55,1,'05318','GUARNE',1,'2026-07-23 21:15:56',NULL),(56,1,'05321','GUATAPÉ',1,'2026-07-23 21:15:56',NULL),(57,1,'05347','HELICONIA',1,'2026-07-23 21:15:56',NULL),(58,1,'05353','HISPANIA',1,'2026-07-23 21:15:56',NULL),(59,1,'05360','ITAGÜÍ',1,'2026-07-23 21:15:56',NULL),(60,1,'05361','ITUANGO',1,'2026-07-23 21:15:56',NULL),(61,1,'05364','JARDÍN',1,'2026-07-23 21:15:56',NULL),(62,1,'05368','JERICÓ',1,'2026-07-23 21:15:56',NULL),(63,1,'05376','LA CEJA',1,'2026-07-23 21:15:56',NULL),(64,1,'05380','LA ESTRELLA',1,'2026-07-23 21:15:56',NULL),(65,1,'05390','LA PINTADA',1,'2026-07-23 21:15:56',NULL),(66,1,'05400','LA UNIÓN',1,'2026-07-23 21:15:56',NULL),(67,1,'05411','LIBORINA',1,'2026-07-23 21:15:56',NULL),(68,1,'05425','MACEO',1,'2026-07-23 21:15:56',NULL),(69,1,'05440','MARINILLA',1,'2026-07-23 21:15:56',NULL),(70,1,'05467','MONTEBELLO',1,'2026-07-23 21:15:56',NULL),(71,1,'05475','MURINDÓ',1,'2026-07-23 21:15:56',NULL),(72,1,'05480','MUTATÁ',1,'2026-07-23 21:15:56',NULL),(73,1,'05483','NARIÑO',1,'2026-07-23 21:15:56',NULL),(74,1,'05490','NECOCLÍ',1,'2026-07-23 21:15:56',NULL),(75,1,'05495','NECHÍ',1,'2026-07-23 21:15:56',NULL),(76,1,'05501','OLAYA',1,'2026-07-23 21:15:56',NULL),(77,1,'05541','PEÑOL',1,'2026-07-23 21:15:56',NULL),(78,1,'05543','PEQUE',1,'2026-07-23 21:15:56',NULL),(79,1,'05576','PUEBLORRICO',1,'2026-07-23 21:15:56',NULL),(80,1,'05579','PUERTO BERRÍO',1,'2026-07-23 21:15:56',NULL),(81,1,'05585','PUERTO NARE',1,'2026-07-23 21:15:56',NULL),(82,1,'05591','PUERTO TRIUNFO',1,'2026-07-23 21:15:56',NULL),(83,1,'05604','REMEDIOS',1,'2026-07-23 21:15:56',NULL),(84,1,'05607','RETIRO',1,'2026-07-23 21:15:56',NULL),(85,1,'05615','RIONEGRO',1,'2026-07-23 21:15:56',NULL),(86,1,'05628','SABANALARGA',1,'2026-07-23 21:15:56',NULL),(87,1,'05631','SABANETA',1,'2026-07-23 21:15:56',NULL),(88,1,'05642','SALGAR',1,'2026-07-23 21:15:56',NULL),(89,1,'05647','SAN ANDRÉS DE CUERQUÍA',1,'2026-07-23 21:15:56',NULL),(90,1,'05649','SAN CARLOS',1,'2026-07-23 21:15:56',NULL),(91,1,'05652','SAN FRANCISCO',1,'2026-07-23 21:15:56',NULL),(92,1,'05656','SAN JERÓNIMO',1,'2026-07-23 21:15:56',NULL),(93,1,'05658','SAN JOSÉ DE LA MONTAÑA',1,'2026-07-23 21:15:56',NULL),(94,1,'05659','SAN JUAN DE URABÁ',1,'2026-07-23 21:15:56',NULL),(95,1,'05660','SAN LUIS',1,'2026-07-23 21:15:56',NULL),(96,1,'05664','SAN PEDRO DE LOS MILAGROS',1,'2026-07-23 21:15:56',NULL),(97,1,'05665','SAN PEDRO DE URABÁ',1,'2026-07-23 21:15:56',NULL),(98,1,'05667','SAN RAFAEL',1,'2026-07-23 21:15:56',NULL),(99,1,'05670','SAN ROQUE',1,'2026-07-23 21:15:56',NULL),(100,1,'05674','SAN VICENTE FERRER',1,'2026-07-23 21:15:56',NULL),(101,1,'05679','SANTA BÁRBARA',1,'2026-07-23 21:15:56',NULL),(102,1,'05686','SANTA ROSA DE OSOS',1,'2026-07-23 21:15:56',NULL),(103,1,'05690','SANTO DOMINGO',1,'2026-07-23 21:15:56',NULL),(104,1,'05697','EL SANTUARIO',1,'2026-07-23 21:15:56',NULL),(105,1,'05736','SEGOVIA',1,'2026-07-23 21:15:56',NULL),(106,1,'05756','SONSÓN',1,'2026-07-23 21:15:56',NULL),(107,1,'05761','SOPETRÁN',1,'2026-07-23 21:15:56',NULL),(108,1,'05789','TÁMESIS',1,'2026-07-23 21:15:56',NULL),(109,1,'05790','TARAZÁ',1,'2026-07-23 21:15:56',NULL),(110,1,'05792','TARSO',1,'2026-07-23 21:15:56',NULL),(111,1,'05809','TITIRIBÍ',1,'2026-07-23 21:15:56',NULL),(112,1,'05819','TOLEDO',1,'2026-07-23 21:15:56',NULL),(113,1,'05837','TURBO',1,'2026-07-23 21:15:56',NULL),(114,1,'05842','URAMITA',1,'2026-07-23 21:15:56',NULL),(115,1,'05847','URRAO',1,'2026-07-23 21:15:56',NULL),(116,1,'05854','VALDIVIA',1,'2026-07-23 21:15:56',NULL),(117,1,'05856','VALPARAÍSO',1,'2026-07-23 21:15:56',NULL),(118,1,'05858','VEGACHÍ',1,'2026-07-23 21:15:56',NULL),(119,1,'05861','VENECIA',1,'2026-07-23 21:15:56',NULL),(120,1,'05873','VIGÍA DEL FUERTE',1,'2026-07-23 21:15:56',NULL),(121,1,'05885','YALÍ',1,'2026-07-23 21:15:56',NULL),(122,1,'05887','YARUMAL',1,'2026-07-23 21:15:56',NULL),(123,1,'05890','YOLOMBÓ',1,'2026-07-23 21:15:56',NULL),(124,1,'05893','YONDÓ',1,'2026-07-23 21:15:56',NULL),(125,1,'05895','ZARAGOZA',1,'2026-07-23 21:15:56',NULL),(126,2,'08001','BARRANQUILLA',1,'2026-07-23 21:15:56',NULL),(127,2,'08078','BARANOA',1,'2026-07-23 21:15:56',NULL),(128,2,'08137','CAMPO DE LA CRUZ',1,'2026-07-23 21:15:56',NULL),(129,2,'08141','CANDELARIA',1,'2026-07-23 21:15:56',NULL),(130,2,'08296','GALAPA',1,'2026-07-23 21:15:56',NULL),(131,2,'08372','JUAN DE ACOSTA',1,'2026-07-23 21:15:56',NULL),(132,2,'08421','LURUACO',1,'2026-07-23 21:15:56',NULL),(133,2,'08433','MALAMBO',1,'2026-07-23 21:15:56',NULL),(134,2,'08436','MANATÍ',1,'2026-07-23 21:15:56',NULL),(135,2,'08520','PALMAR DE VARELA',1,'2026-07-23 21:15:56',NULL),(136,2,'08549','PIOJÓ',1,'2026-07-23 21:15:56',NULL),(137,2,'08558','POLONUEVO',1,'2026-07-23 21:15:56',NULL),(138,2,'08560','PONEDERA',1,'2026-07-23 21:15:56',NULL),(139,2,'08573','PUERTO COLOMBIA',1,'2026-07-23 21:15:56',NULL),(140,2,'08606','REPELÓN',1,'2026-07-23 21:15:56',NULL),(141,2,'08634','SABANAGRANDE',1,'2026-07-23 21:15:56',NULL),(142,2,'08638','SABANALARGA',1,'2026-07-23 21:15:56',NULL),(143,2,'08675','SANTA LUCÍA',1,'2026-07-23 21:15:56',NULL),(144,2,'08685','SANTO TOMÁS',1,'2026-07-23 21:15:56',NULL),(145,2,'08758','SOLEDAD',1,'2026-07-23 21:15:56',NULL),(146,2,'08770','SUAN',1,'2026-07-23 21:15:56',NULL),(147,2,'08832','TUBARÁ',1,'2026-07-23 21:15:56',NULL),(148,2,'08849','USIACURÍ',1,'2026-07-23 21:15:56',NULL),(149,3,'11001','BOGOTÁ, D.C.',1,'2026-07-23 21:15:56',NULL),(150,33,'99773','CUMARIBO',1,'2026-07-23 21:15:56',NULL),(151,34,'00000','Extranjero',1,'2026-07-24 06:52:27',NULL),(152,11,'25175','CHÍA',1,'2026-07-24 12:11:15',NULL),(153,11,'25899','ZIPAQUIRÁ',1,'2026-07-24 12:11:15',NULL),(154,11,'25295','GACHANCIPÁ',1,'2026-07-24 12:11:15',NULL);
/*!40000 ALTER TABLE `bbf_municipios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_parametros_sistema`
--

DROP TABLE IF EXISTS `bbf_parametros_sistema`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_parametros_sistema` (
  `ID_PARAMETRO` int(11) NOT NULL AUTO_INCREMENT,
  `CODIGO` varchar(100) NOT NULL,
  `NOMBRE` varchar(150) NOT NULL,
  `GRUPO` varchar(100) NOT NULL DEFAULT 'GENERAL',
  `DESCRIPCION` varchar(500) DEFAULT NULL,
  `TIPO_DATO` enum('TEXTO','NUMERICO','FECHA','BOOLEANO','JSON') NOT NULL,
  `VALOR` longtext NOT NULL,
  `UNIDAD_MEDIDA` varchar(50) DEFAULT NULL,
  `VIGENCIA_DESDE` date NOT NULL,
  `VIGENCIA_HASTA` date DEFAULT NULL,
  `ACTIVO` tinyint(1) NOT NULL DEFAULT 1,
  `EDITABLE` tinyint(1) NOT NULL DEFAULT 1,
  `ID_CREADO_POR` int(11) DEFAULT NULL,
  `ID_ACTUALIZADO_POR` int(11) DEFAULT NULL,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_PARAMETRO`),
  UNIQUE KEY `UQ_BBF_PARAMETRO_CODIGO_VIGENCIA` (`CODIGO`,`VIGENCIA_DESDE`),
  KEY `IDX_BBF_PARAMETRO_GRUPO` (`GRUPO`),
  KEY `IDX_BBF_PARAMETRO_BUSQUEDA_VIGENTE` (`CODIGO`,`ACTIVO`,`VIGENCIA_DESDE`,`VIGENCIA_HASTA`),
  KEY `FK_BBF_PARAMETRO_CREADO_POR` (`ID_CREADO_POR`),
  KEY `FK_BBF_PARAMETRO_ACTUALIZADO_POR` (`ID_ACTUALIZADO_POR`),
  CONSTRAINT `FK_BBF_PARAMETRO_ACTUALIZADO_POR` FOREIGN KEY (`ID_ACTUALIZADO_POR`) REFERENCES `bbf_usuarios` (`ID_USUARIO`),
  CONSTRAINT `FK_BBF_PARAMETRO_CREADO_POR` FOREIGN KEY (`ID_CREADO_POR`) REFERENCES `bbf_usuarios` (`ID_USUARIO`),
  CONSTRAINT `CK_BBF_PARAMETRO_VIGENCIA` CHECK (`VIGENCIA_HASTA` is null or `VIGENCIA_HASTA` >= `VIGENCIA_DESDE`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_parametros_sistema`
--

LOCK TABLES `bbf_parametros_sistema` WRITE;
/*!40000 ALTER TABLE `bbf_parametros_sistema` DISABLE KEYS */;
INSERT INTO `bbf_parametros_sistema` VALUES (1,'SALARIO_MINIMO','Salario mínimo legal vigente','LABORAL','Valor mínimo permitido para el salario base de los contratos.','NUMERICO','1750905','COP','2026-01-01','2026-12-31',1,1,NULL,NULL,'2026-08-10 17:26:31',NULL);
/*!40000 ALTER TABLE `bbf_parametros_sistema` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_permisos`
--

DROP TABLE IF EXISTS `bbf_permisos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_permisos` (
  `ID_PERMISO` int(11) NOT NULL AUTO_INCREMENT,
  `CODIGO` varchar(120) NOT NULL,
  `NOMBRE` varchar(150) NOT NULL,
  `DESCRIPCION` text DEFAULT NULL,
  `MODULO` varchar(100) NOT NULL,
  `ACTIVO` tinyint(1) NOT NULL DEFAULT 1,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_PERMISO`),
  UNIQUE KEY `UQ_BBF_PERMISOS_CODIGO` (`CODIGO`)
) ENGINE=InnoDB AUTO_INCREMENT=77 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_permisos`
--

LOCK TABLES `bbf_permisos` WRITE;
/*!40000 ALTER TABLE `bbf_permisos` DISABLE KEYS */;
INSERT INTO `bbf_permisos` VALUES (1,'DASHBOARD_VER','Ver dashboard','Ver dashboard','DASHBOARD',1,'2026-06-22 16:00:50',NULL),(2,'USUARIOS_VER','Ver usuario','Ver usuario','USUARIOS',1,'2026-06-22 16:00:50',NULL),(3,'USUARIOS_LISTAR','Listar usuarios','Listar usuarios','USUARIOS',1,'2026-06-22 16:00:50',NULL),(4,'USUARIOS_CREAR','Crear usuarios','Crear usuarios','USUARIOS',1,'2026-06-22 16:00:50',NULL),(5,'USUARIOS_EDITAR','Editar usuarios','Editar usuarios','USUARIOS',1,'2026-06-22 16:00:50',NULL),(6,'USUARIOS_INACTIVAR','Inactivar usuarios','Inactivar usuarios','USUARIOS',1,'2026-06-22 16:00:50',NULL),(7,'USUARIOS_CAMBIAR_ESTADO','Cambiar estado de usuarios','Cambiar estado de usuarios','USUARIOS',1,'2026-06-22 16:00:50',NULL),(8,'USUARIOS_ASIGNAR_ROL','Asignar roles a usuarios','Asignar roles a usuarios','USUARIOS',1,'2026-06-22 16:00:50',NULL),(9,'USUARIOS_QUITAR_ROL','Retirar roles de usuarios','Retirar roles de usuarios','USUARIOS',1,'2026-06-22 16:00:50',NULL),(10,'USUARIOS_VER_ROLES','Ver roles de usuarios','Ver roles de usuarios','USUARIOS',1,'2026-06-22 16:00:50',NULL),(11,'USUARIOS_VER_PERMISOS','Ver permisos de usuarios','Ver permisos de usuarios','USUARIOS',1,'2026-06-22 16:00:50',NULL),(12,'ROLES_VER','Ver rol','Ver rol','ROLES',1,'2026-06-22 16:00:50',NULL),(13,'ROLES_LISTAR','Listar roles','Listar roles','ROLES',1,'2026-06-22 16:00:50',NULL),(14,'ROLES_CREAR','Crear roles','Crear roles','ROLES',1,'2026-06-22 16:00:50',NULL),(15,'ROLES_EDITAR','Editar roles','Editar roles','ROLES',1,'2026-06-22 16:00:50',NULL),(16,'PERMISOS_VER','Ver permisos','Ver permisos','PERMISOS',1,'2026-06-22 16:00:50',NULL),(17,'PERMISOS_LISTAR','Listar permisos','Listar permisos','PERMISOS',1,'2026-06-22 16:00:50',NULL),(18,'EMPLEADOS_VER','Ver empleado','Ver detalle de empleado','EMPLEADOS',1,'2026-06-22 16:00:50','2026-06-22 22:34:43'),(19,'EMPLEADOS_LISTAR','Listar empleados','Listar empleados','EMPLEADOS',1,'2026-06-22 22:34:43',NULL),(20,'EMPLEADOS_CREAR','Crear empleado','Crear empleados','EMPLEADOS',1,'2026-06-22 22:34:43',NULL),(21,'EMPLEADOS_EDITAR','Editar empleado','Editar empleados','EMPLEADOS',1,'2026-06-22 22:34:43',NULL),(22,'EMPLEADOS_CAMBIAR_ESTADO','Cambiar estado de empleado','Cambiar estado de empleados','EMPLEADOS',1,'2026-06-22 22:34:43',NULL),(23,'EMPLEADOS_ELIMINAR','Eliminar empleado','Eliminar lógicamente empleados','EMPLEADOS',1,'2026-06-22 22:34:43',NULL),(24,'DOTACIONES_VER','Ver módulo de dotaciones','Permite ver el módulo de dotaciones en el menú','Dotaciones',1,'2026-06-23 11:01:54',NULL),(25,'DOTACIONES_MIS_TALLAS_VER','Ver mis tallas de dotación','Permite al empleado consultar sus tallas de dotación','Dotaciones',1,'2026-06-23 11:01:54',NULL),(26,'DOTACIONES_MIS_TALLAS_EDITAR','Editar mis tallas de dotación','Permite al empleado registrar o actualizar sus tallas de dotación','Dotaciones',1,'2026-06-23 11:01:54',NULL),(27,'DOTACIONES_ADMIN_VER','Ver dotaciones del personal','Permite a RRHH o administrador consultar tallas de empleados','Dotaciones',1,'2026-06-23 11:01:54',NULL),(28,'DOTACIONES_EMPLEADO_VER','Ver tallas de un empleado','Permite consultar las tallas de dotación de un empleado específico','Dotaciones',1,'2026-06-23 11:01:54',NULL),(29,'DOTACIONES_ENTREGAS_VER','Ver entregas de dotación','Permite consultar entregas de dotación realizadas','Dotaciones',1,'2026-06-23 11:01:54',NULL),(30,'DOTACIONES_ENTREGAS_CREAR','Crear entrega de dotación','Permite registrar entregas de dotación al personal','Dotaciones',1,'2026-06-23 11:01:54',NULL),(31,'DOTACIONES_CATALOGOS_VER','Ver catálogos de dotación','Permite consultar tipos y tallas de dotación','Dotaciones',1,'2026-06-23 11:01:54',NULL),(32,'DOTACIONES_MIS_ENTREGAS_VER','Ver mis entregas de dotación','Permite al empleado consultar sus entregas de dotación','Dotaciones',1,'2026-06-23 19:24:43',NULL),(33,'DOTACIONES_MIS_ENTREGAS_CONFIRMAR','Confirmar recibido de dotación','Permite al empleado confirmar que recibió una entrega de dotación','Dotaciones',1,'2026-06-23 19:24:43',NULL),(34,'DOTACIONES_ENTREGAS_ELIMINAR','Eliminar entrega de dotación','Permite eliminar lógicamente una entrega de dotación no confirmada','Dotaciones',1,'2026-06-23 21:36:23',NULL),(35,'CONTRATACION_VER','Ver módulo de contratación','Permite ver el módulo de contratación','Contratación',1,'2026-06-23 22:41:18',NULL),(36,'CONTRATACION_CREAR','Crear ficha de contratación','Permite crear información de contratación del empleado','Contratación',1,'2026-06-23 22:41:18',NULL),(37,'CONTRATACION_EDITAR','Editar ficha de contratación','Permite editar información de contratación del empleado','Contratación',1,'2026-06-23 22:41:18',NULL),(38,'CONTRATACION_ELIMINAR','Eliminar contratación','Permite eliminar lógicamente registros de contratación','Contratación',1,'2026-06-23 22:41:18',NULL),(39,'CONTRATACION_HISTORIAL_VER','Ver historial contractual','Permite consultar historial contractual del empleado','Contratación',1,'2026-06-23 22:41:18',NULL),(40,'CONTRATACION_DOCUMENTOS_VER','Ver documentos de contratación','Permite consultar documentos laborales del empleado','Contratación',1,'2026-06-23 22:41:18',NULL),(41,'CONTRATACION_DOCUMENTOS_SUBIR','Subir documentos de contratación','Permite cargar documentos laborales del empleado','Contratación',1,'2026-06-23 22:41:18',NULL),(42,'CONTRATACION_DOCUMENTOS_VALIDAR','Validar documentos de contratación','Permite validar documentos laborales cargados','Contratación',1,'2026-06-23 22:41:18',NULL),(43,'CONTRATACION_DOCUMENTOS_RECHAZAR','Rechazar documentos de contratación','Permite rechazar documentos laborales cargados','Contratación',1,'2026-06-23 22:41:18',NULL),(44,'CONTRATACION_DOCUMENTOS_ELIMINAR','Eliminar documentos de contratación','Permite eliminar lógicamente documentos laborales','Contratación',1,'2026-06-23 22:41:18',NULL),(45,'CONTRATACION_SEGURIDAD_SOCIAL_VER','Ver seguridad social','Permite consultar seguridad social del empleado','Contratación',1,'2026-06-23 22:41:18',NULL),(46,'CONTRATACION_SEGURIDAD_SOCIAL_EDITAR','Editar seguridad social','Permite registrar o editar seguridad social del empleado','Contratación',1,'2026-06-23 22:41:18',NULL),(47,'CONTRATACION_EXAMENES_VER','Ver exámenes médicos','Permite consultar exámenes médicos del empleado','Contratación',1,'2026-06-23 22:41:18',NULL),(48,'CONTRATACION_EXAMENES_CREAR','Crear examen médico','Permite registrar exámenes médicos del empleado','Contratación',1,'2026-06-23 22:41:18',NULL),(49,'CONTRATACION_EXAMENES_EDITAR','Editar examen médico','Permite editar exámenes médicos del empleado','Contratación',1,'2026-06-23 22:41:18',NULL),(50,'CONTRATACION_ALERTAS_VER','Ver alertas de contratación','Permite consultar alertas de contratos, documentos y exámenes','Contratación',1,'2026-06-23 22:41:18',NULL),(51,'ASPIRANTES_VER','Ver aspirantes','Permite consultar aspirantes','Aspirantes',1,'2026-06-24 13:33:28',NULL),(52,'ASPIRANTES_CREAR','Crear aspirantes','Permite registrar aspirantes','Aspirantes',1,'2026-06-24 13:33:28',NULL),(53,'ASPIRANTES_EDITAR','Editar aspirantes','Permite editar información de aspirantes','Aspirantes',1,'2026-06-24 13:33:28',NULL),(54,'ASPIRANTES_CAMBIAR_ESTADO','Cambiar estado de aspirantes','Permite cambiar el estado del aspirante dentro del proceso','Aspirantes',1,'2026-06-24 13:33:28',NULL),(55,'ASPIRANTES_DOCUMENTOS_VER','Ver documentos de aspirantes','Permite consultar documentos cargados al aspirante','Aspirantes',1,'2026-06-24 13:33:28',NULL),(56,'ASPIRANTES_DOCUMENTOS_SUBIR','Subir documentos de aspirantes','Permite registrar documentos del aspirante','Aspirantes',1,'2026-06-24 13:33:28',NULL),(57,'ASPIRANTES_APROBAR_CONTRATACION','Aprobar aspirante para contratación','Permite aprobar el aspirante para iniciar contratación formal','Aspirantes',1,'2026-06-24 13:33:28',NULL),(58,'ASPIRANTES_CONVERTIR_EMPLEADO','Convertir aspirante en empleado','Permite convertir un aspirante aprobado en empleado','Aspirantes',1,'2026-06-24 13:33:28',NULL),(59,'HERRAMIENTAS_LISTAR','Listar herramientas','Permite consultar el catálogo y las entregas de herramientas','HERRAMIENTAS',1,'2026-07-27 14:00:42',NULL),(60,'HERRAMIENTAS_CREAR','Crear herramientas','Permite registrar herramientas en el catálogo','HERRAMIENTAS',1,'2026-07-27 14:00:42',NULL),(61,'HERRAMIENTAS_EDITAR','Editar herramientas','Permite editar y cambiar el estado de herramientas','HERRAMIENTAS',1,'2026-07-27 14:00:42',NULL),(62,'HERRAMIENTAS_ENTREGAR','Entregar herramientas','Permite registrar entregas de herramientas a empleados','HERRAMIENTAS',1,'2026-07-27 14:00:42',NULL),(63,'HERRAMIENTAS_CONFIRMAR','Confirmar herramientas','Permite confirmar la recepción de herramientas','HERRAMIENTAS',1,'2026-07-27 14:00:42',NULL),(64,'HERRAMIENTAS_ELIMINAR','Eliminar entregas de herramientas','Permite eliminar entregas de herramientas cuando el estado lo permita','HERRAMIENTAS',1,'2026-07-27 14:00:42',NULL),(65,'HERRAMIENTAS_MIS_ENTREGAS_VER','Ver mis entregas de herramientas','Permite al empleado consultar únicamente sus propias entregas de herramientas','HERRAMIENTAS',1,'2026-07-27 14:07:27',NULL),(66,'DEVOLUCIONES_VER','Ver devoluciones','Permite listar y consultar devoluciones','DEVOLUCIONES',1,'2026-07-29 19:44:01',NULL),(67,'DEVOLUCIONES_CREAR','Crear devoluciones','Permite consultar disponibles y registrar devoluciones','DEVOLUCIONES',1,'2026-07-29 19:44:01',NULL),(68,'DEVOLUCIONES_CONFIRMAR','Confirmar devoluciones','Permite confirmar devoluciones registradas','DEVOLUCIONES',1,'2026-07-29 19:44:01',NULL),(69,'DEVOLUCIONES_ANULAR','Anular devoluciones','Permite anular devoluciones conservando trazabilidad','DEVOLUCIONES',1,'2026-07-29 19:44:01',NULL),(70,'CAPACITACIONES_VER','Ver capacitaciones','Permite consultar catalogos, sesiones, participantes y resultados.','CAPACITACIONES',1,'2026-08-03 16:40:02',NULL),(71,'CAPACITACIONES_ADMINISTRAR','Administrar capacitaciones','Permite crear catalogos, sesiones y asociar participantes.','CAPACITACIONES',1,'2026-08-03 16:40:02',NULL),(72,'CAPACITACIONES_EVALUAR','Evaluar capacitaciones','Permite registrar evaluaciones y resultados.','CAPACITACIONES',1,'2026-08-03 16:40:02',NULL),(73,'CAPACITACIONES_IMPORTAR','Importar evaluaciones','Permite cargar e importar archivos Excel de evaluacion.','CAPACITACIONES',1,'2026-08-03 16:40:02',NULL),(74,'CAPACITACIONES_COMPROMISOS','Gestionar compromisos','Permite generar y actualizar cartas de compromiso.','CAPACITACIONES',1,'2026-08-03 16:40:02',NULL),(75,'CAPACITACIONES_MIS_REGISTROS_VER','Ver mis capacitaciones','Permite al empleado consultar sus capacitaciones y resultados.','CAPACITACIONES',1,'2026-08-03 16:40:02',NULL),(76,'CAPACITACIONES_CONFIRMAR','Confirmar capacitacion recibida','Permite al empleado confirmar que recibio una capacitacion.','CAPACITACIONES',1,'2026-08-03 16:40:02',NULL);
/*!40000 ALTER TABLE `bbf_permisos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_rol_permisos`
--

DROP TABLE IF EXISTS `bbf_rol_permisos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_rol_permisos` (
  `ID_ROL_PERMISO` int(11) NOT NULL AUTO_INCREMENT,
  `ID_ROL` int(11) NOT NULL,
  `ID_PERMISO` int(11) NOT NULL,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`ID_ROL_PERMISO`),
  UNIQUE KEY `UQ_BBF_ROL_PERMISOS` (`ID_ROL`,`ID_PERMISO`),
  KEY `FK_BBF_ROL_PERMISOS_PERMISO` (`ID_PERMISO`),
  CONSTRAINT `FK_BBF_ROL_PERMISOS_PERMISO` FOREIGN KEY (`ID_PERMISO`) REFERENCES `bbf_permisos` (`ID_PERMISO`) ON DELETE CASCADE,
  CONSTRAINT `FK_BBF_ROL_PERMISOS_ROL` FOREIGN KEY (`ID_ROL`) REFERENCES `bbf_roles` (`ID_ROL`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=115 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_rol_permisos`
--

LOCK TABLES `bbf_rol_permisos` WRITE;
/*!40000 ALTER TABLE `bbf_rol_permisos` DISABLE KEYS */;
INSERT INTO `bbf_rol_permisos` VALUES (1,1,1,'2026-06-22 16:00:50'),(2,1,2,'2026-06-22 16:00:50'),(3,1,3,'2026-06-22 16:00:50'),(4,1,4,'2026-06-22 16:00:50'),(5,1,5,'2026-06-22 16:00:50'),(6,1,6,'2026-06-22 16:00:50'),(7,1,7,'2026-06-22 16:00:50'),(8,1,8,'2026-06-22 16:00:50'),(9,1,9,'2026-06-22 16:00:50'),(10,1,10,'2026-06-22 16:00:50'),(11,1,11,'2026-06-22 16:00:50'),(12,1,12,'2026-06-22 16:00:50'),(13,1,13,'2026-06-22 16:00:50'),(14,1,14,'2026-06-22 16:00:50'),(15,1,15,'2026-06-22 16:00:50'),(16,1,16,'2026-06-22 16:00:50'),(17,1,17,'2026-06-22 16:00:50'),(18,1,18,'2026-06-22 16:00:50'),(39,6,2,'2026-06-22 22:17:06'),(40,1,19,'2026-06-22 22:42:56'),(41,1,20,'2026-06-22 22:42:56'),(42,1,21,'2026-06-22 22:42:56'),(43,1,22,'2026-06-22 22:42:56'),(44,1,23,'2026-06-22 22:42:56'),(45,1,27,'2026-06-23 11:07:32'),(46,1,31,'2026-06-23 11:07:34'),(47,1,28,'2026-06-23 11:07:37'),(48,1,30,'2026-06-23 11:07:40'),(49,1,29,'2026-06-23 11:07:48'),(50,1,26,'2026-06-23 11:07:52'),(51,1,25,'2026-06-23 11:07:55'),(52,1,24,'2026-06-23 11:07:58'),(54,7,26,'2026-06-23 11:52:30'),(55,7,24,'2026-06-23 11:52:36'),(56,7,25,'2026-06-23 11:52:44'),(57,7,31,'2026-06-23 11:53:33'),(58,7,33,'2026-06-23 20:20:37'),(59,7,29,'2026-06-23 20:21:25'),(60,7,32,'2026-06-23 20:22:46'),(66,1,34,'2026-06-23 22:05:20'),(67,1,33,'2026-06-23 22:05:26'),(68,1,32,'2026-06-23 22:05:28'),(69,1,35,'2026-06-23 22:45:36'),(70,1,36,'2026-06-23 22:45:36'),(71,1,37,'2026-06-23 22:45:36'),(72,1,38,'2026-06-23 22:45:36'),(73,1,39,'2026-06-23 22:45:36'),(74,1,40,'2026-06-23 22:45:36'),(75,1,41,'2026-06-23 22:45:36'),(76,1,42,'2026-06-23 22:45:36'),(77,1,43,'2026-06-23 22:45:36'),(78,1,44,'2026-06-23 22:45:36'),(79,1,45,'2026-06-23 22:45:36'),(80,1,46,'2026-06-23 22:45:36'),(81,1,47,'2026-06-23 22:45:36'),(82,1,48,'2026-06-23 22:45:36'),(83,1,49,'2026-06-23 22:45:36'),(84,1,50,'2026-06-23 22:45:36'),(85,1,51,'2026-06-24 13:35:12'),(86,1,52,'2026-06-24 13:35:12'),(87,1,53,'2026-06-24 13:35:12'),(88,1,54,'2026-06-24 13:35:12'),(89,1,55,'2026-06-24 13:35:12'),(90,1,56,'2026-06-24 13:35:12'),(91,1,57,'2026-06-24 13:35:12'),(92,1,58,'2026-06-24 13:35:12'),(93,1,63,'2026-07-27 14:02:04'),(94,1,60,'2026-07-27 14:02:07'),(95,1,61,'2026-07-27 14:02:09'),(96,1,64,'2026-07-27 14:02:11'),(97,1,62,'2026-07-27 14:02:13'),(98,1,59,'2026-07-27 14:02:15'),(99,7,63,'2026-07-27 14:04:20'),(100,7,65,'2026-07-27 14:07:32'),(101,1,69,'2026-07-29 19:44:26'),(102,1,68,'2026-07-29 19:44:28'),(103,1,67,'2026-07-29 19:44:29'),(104,1,66,'2026-07-29 19:44:31'),(105,1,65,'2026-07-29 19:44:34'),(106,1,71,'2026-08-03 16:40:02'),(107,1,74,'2026-08-03 16:40:02'),(108,1,76,'2026-08-03 16:40:02'),(109,1,72,'2026-08-03 16:40:02'),(110,1,73,'2026-08-03 16:40:02'),(111,1,75,'2026-08-03 16:40:02'),(112,1,70,'2026-08-03 16:40:02'),(113,7,76,'2026-08-03 16:40:02'),(114,7,75,'2026-08-03 16:40:02');
/*!40000 ALTER TABLE `bbf_rol_permisos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_roles`
--

DROP TABLE IF EXISTS `bbf_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_roles` (
  `ID_ROL` int(11) NOT NULL AUTO_INCREMENT,
  `NOMBRE` varchar(100) NOT NULL,
  `DESCRIPCION` text DEFAULT NULL,
  `ACTIVO` tinyint(1) NOT NULL DEFAULT 1,
  `ELIMINADO` tinyint(1) NOT NULL DEFAULT 0,
  `FECHA_ELIMINACION` datetime DEFAULT NULL,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_ROL`),
  UNIQUE KEY `UQ_BBF_ROLES_NOMBRE` (`NOMBRE`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_roles`
--

LOCK TABLES `bbf_roles` WRITE;
/*!40000 ALTER TABLE `bbf_roles` DISABLE KEYS */;
INSERT INTO `bbf_roles` VALUES (1,'SUPER_ADMIN','Administrador inicial con acceso completo al sistema.',1,0,NULL,'2026-06-22 16:00:50',NULL),(2,'RH_Rol','Rol para recursos humanos',0,1,'2026-06-22 22:07:22','2026-06-22 18:19:32','2026-06-22 22:07:22'),(6,'Rol contabilidad','Rol para contabilidad',0,1,'2026-06-23 20:20:24','2026-06-22 22:16:24','2026-06-23 20:20:24'),(7,'EMPLEADO_ROL','Rol para el empleado',1,0,NULL,'2026-06-23 11:52:05',NULL);
/*!40000 ALTER TABLE `bbf_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_tallas_dotacion`
--

DROP TABLE IF EXISTS `bbf_tallas_dotacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_tallas_dotacion` (
  `ID_TALLA_DOTACION` int(11) NOT NULL AUTO_INCREMENT,
  `ID_TIPO_DOTACION` int(11) NOT NULL,
  `TALLA` varchar(50) NOT NULL,
  `DESCRIPCION` varchar(150) DEFAULT NULL,
  `ORDEN` int(11) NOT NULL DEFAULT 0,
  `ACTIVO` tinyint(1) NOT NULL DEFAULT 1,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_TALLA_DOTACION`),
  UNIQUE KEY `UQ_BBF_TALLAS_DOTACION` (`ID_TIPO_DOTACION`,`TALLA`),
  UNIQUE KEY `UQ_BBF_TALLA_DOTACION_TIPO` (`ID_TALLA_DOTACION`,`ID_TIPO_DOTACION`),
  CONSTRAINT `FK_BBF_TALLAS_DOTACION_TIPO` FOREIGN KEY (`ID_TIPO_DOTACION`) REFERENCES `bbf_tipos_dotacion` (`ID_TIPO_DOTACION`)
) ENGINE=InnoDB AUTO_INCREMENT=108 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_tallas_dotacion`
--

LOCK TABLES `bbf_tallas_dotacion` WRITE;
/*!40000 ALTER TABLE `bbf_tallas_dotacion` DISABLE KEYS */;
INSERT INTO `bbf_tallas_dotacion` VALUES (1,1,'XS','Extra pequeña',1,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(2,7,'XS','Extra pequeña',1,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(3,6,'XS','Extra pequeña',1,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(4,2,'XS','Extra pequeña',1,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(5,1,'S','Pequeña',2,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(6,7,'S','Pequeña',2,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(7,6,'S','Pequeña',2,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(8,2,'S','Pequeña',2,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(9,1,'M','Mediana',3,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(10,7,'M','Mediana',3,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(11,6,'M','Mediana',3,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(12,2,'M','Mediana',3,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(13,1,'L','Grande',4,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(14,7,'L','Grande',4,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(15,6,'L','Grande',4,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(16,2,'L','Grande',4,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(17,1,'XL','Extra grande',5,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(18,7,'XL','Extra grande',5,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(19,6,'XL','Extra grande',5,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(20,2,'XL','Extra grande',5,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(21,1,'XXL','Doble extra grande',6,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(22,7,'XXL','Doble extra grande',6,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(23,6,'XXL','Doble extra grande',6,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(24,2,'XXL','Doble extra grande',6,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(32,3,'34','Calzado talla 34',34,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(33,3,'35','Calzado talla 35',35,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(34,3,'36','Calzado talla 36',36,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(35,3,'37','Calzado talla 37',37,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(36,3,'38','Calzado talla 38',38,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(37,3,'39','Calzado talla 39',39,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(38,3,'40','Calzado talla 40',40,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(39,3,'41','Calzado talla 41',41,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(40,3,'42','Calzado talla 42',42,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(41,3,'43','Calzado talla 43',43,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(47,5,'S','Pequeña',1,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(48,4,'S','Pequeña',1,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(49,5,'M','Mediana',2,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(50,4,'M','Mediana',2,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(51,5,'L','Grande',3,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(52,4,'L','Grande',3,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(53,5,'Única','Talla única',4,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(54,4,'Única','Talla única',4,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(65,10,'L','Grande',4,1,'2026-07-24 09:36:22',NULL),(66,10,'M','Mediana',3,1,'2026-07-24 09:36:22',NULL),(67,10,'S','Pequeña',2,1,'2026-07-24 09:36:22',NULL),(68,10,'XL','Extra grande',5,1,'2026-07-24 09:36:22',NULL),(69,10,'XS','Extra pequeña',1,1,'2026-07-24 09:36:22',NULL),(70,10,'XXL','Doble extra grande',6,1,'2026-07-24 09:36:22',NULL),(72,9,'UNICA','Talla única',1,1,'2026-07-24 10:55:43',NULL),(73,10,'12','Bata talla 12',112,1,'2026-08-10 10:19:40',NULL),(74,10,'14','Bata talla 14',114,1,'2026-08-10 10:19:40',NULL),(75,10,'16','Bata talla 16',116,1,'2026-08-10 10:19:40',NULL),(76,9,'10','Overol talla 10',110,1,'2026-08-10 10:19:40',NULL),(77,9,'12','Overol talla 12',112,1,'2026-08-10 10:19:40',NULL),(78,9,'14','Overol talla 14',114,1,'2026-08-10 10:19:40',NULL),(79,9,'16','Overol talla 16',116,1,'2026-08-10 10:19:40',NULL),(80,9,'28','Overol talla 28',128,1,'2026-08-10 10:19:40',NULL),(81,9,'30','Overol talla 30',130,1,'2026-08-10 10:19:40',NULL),(82,9,'32','Overol talla 32',132,1,'2026-08-10 10:19:40',NULL),(83,9,'34','Overol talla 34',134,1,'2026-08-10 10:19:40',NULL),(84,9,'36','Overol talla 36',136,1,'2026-08-10 10:19:40',NULL),(85,9,'38','Overol talla 38',138,1,'2026-08-10 10:19:40',NULL),(86,9,'40','Overol talla 40',140,1,'2026-08-10 10:19:40',NULL),(87,9,'6','Overol talla 6',106,1,'2026-08-10 10:19:40',NULL),(88,9,'8','Overol talla 8',108,1,'2026-08-10 10:19:40',NULL),(89,9,'L','Grande',4,1,'2026-08-10 10:19:40',NULL),(90,9,'M','Mediana',3,1,'2026-08-10 10:19:40',NULL),(91,9,'S','Pequeña',2,1,'2026-08-10 10:19:40',NULL),(92,9,'XL','Extra grande',5,1,'2026-08-10 10:19:40',NULL),(93,9,'XS','Extra pequeña',1,1,'2026-08-10 10:19:40',NULL),(94,9,'XXL','Doble extra grande',6,1,'2026-08-10 10:19:40',NULL),(95,2,'10','Pantalón talla 10',10,1,'2026-08-10 10:19:40',NULL),(96,2,'12','Pantalón talla 12',12,1,'2026-08-10 10:19:40',NULL),(97,2,'14','Pantalón talla 14',14,1,'2026-08-10 10:19:40',NULL),(98,2,'16','Pantalón talla 16',16,1,'2026-08-10 10:19:40',NULL),(99,2,'28','Pantalón talla 28',28,1,'2026-08-10 10:19:40',NULL),(100,2,'30','Pantalón talla 30',30,1,'2026-08-10 10:19:40',NULL),(101,2,'32','Pantalón talla 32',32,1,'2026-08-10 10:19:40',NULL),(102,2,'34','Pantalón talla 34',34,1,'2026-08-10 10:19:40',NULL),(103,2,'36','Pantalón talla 36',36,1,'2026-08-10 10:19:40',NULL),(104,2,'38','Pantalón talla 38',38,1,'2026-08-10 10:19:40',NULL),(105,2,'40','Pantalón talla 40',40,1,'2026-08-10 10:19:40',NULL),(106,2,'6','Pantalón talla 6',6,1,'2026-08-10 10:19:40',NULL),(107,2,'8','Pantalón talla 8',8,1,'2026-08-10 10:19:40',NULL);
/*!40000 ALTER TABLE `bbf_tallas_dotacion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_tipos_contrato`
--

DROP TABLE IF EXISTS `bbf_tipos_contrato`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_tipos_contrato` (
  `ID_TIPO_CONTRATO` int(11) NOT NULL AUTO_INCREMENT,
  `NOMBRE` varchar(100) NOT NULL,
  `DESCRIPCION` text DEFAULT NULL,
  `ACTIVO` tinyint(1) NOT NULL DEFAULT 1,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_TIPO_CONTRATO`),
  UNIQUE KEY `UQ_BBF_TIPOS_CONTRATO_NOMBRE` (`NOMBRE`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_tipos_contrato`
--

LOCK TABLES `bbf_tipos_contrato` WRITE;
/*!40000 ALTER TABLE `bbf_tipos_contrato` DISABLE KEYS */;
INSERT INTO `bbf_tipos_contrato` VALUES (2,'Indefinido','Contrato laboral a término indefinido',1,'2026-06-23 10:00:15',NULL),(3,'Fijo','Contrato laboral a término fijo',1,'2026-06-23 10:00:15',NULL),(4,'Obra o labor','Contrato por duración de obra o labor determinada',1,'2026-06-23 10:00:15',NULL),(5,'Prestación de servicios','Contrato civil o comercial por prestación de servicios',0,'2026-06-23 10:00:15','2026-07-23 11:15:55'),(6,'Aprendizaje','Contrato de aprendizaje',0,'2026-06-23 10:00:15','2026-07-23 11:15:55'),(7,'Temporal','Vinculación temporal o por temporada',0,'2026-06-23 10:00:15','2026-07-23 11:15:55'),(8,'Prácticas','Vinculación para prácticas académicas o profesionales',0,'2026-06-23 10:00:15','2026-07-23 11:15:55');
/*!40000 ALTER TABLE `bbf_tipos_contrato` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_tipos_documento`
--

DROP TABLE IF EXISTS `bbf_tipos_documento`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_tipos_documento` (
  `ID_TIPO_DOCUMENTO` int(11) NOT NULL AUTO_INCREMENT,
  `NOMBRE` varchar(80) NOT NULL,
  `ACTIVO` tinyint(1) NOT NULL DEFAULT 1,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_TIPO_DOCUMENTO`),
  UNIQUE KEY `UQ_BBF_TIPOS_DOCUMENTO_NOMBRE` (`NOMBRE`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_tipos_documento`
--

LOCK TABLES `bbf_tipos_documento` WRITE;
/*!40000 ALTER TABLE `bbf_tipos_documento` DISABLE KEYS */;
INSERT INTO `bbf_tipos_documento` VALUES (2,'Cédula de ciudadanía',1,'2026-06-23 09:32:04',NULL),(3,'Cédula de extranjería',1,'2026-06-23 09:32:04',NULL),(4,'Tarjeta de identidad',1,'2026-06-23 09:32:04',NULL),(5,'Registro civil',1,'2026-06-23 09:32:04',NULL),(6,'Pasaporte',1,'2026-06-23 09:32:04',NULL),(7,'Permiso Especial de Permanencia - PEP',1,'2026-06-23 09:32:04',NULL),(8,'Permiso por Protección Temporal - PPT',1,'2026-06-23 09:32:04',NULL),(9,'Número de Identificación Tributaria - NIT',1,'2026-06-23 09:32:04',NULL),(10,'Documento Nacional de Identidad extranjero',1,'2026-06-23 09:32:04',NULL),(11,'Otro',1,'2026-06-23 09:32:04',NULL);
/*!40000 ALTER TABLE `bbf_tipos_documento` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_tipos_documento_laboral`
--

DROP TABLE IF EXISTS `bbf_tipos_documento_laboral`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_tipos_documento_laboral` (
  `ID_TIPO_DOCUMENTO_LABORAL` int(11) NOT NULL AUTO_INCREMENT,
  `NOMBRE` varchar(150) NOT NULL,
  `DESCRIPCION` varchar(500) DEFAULT NULL,
  `OBLIGATORIO` tinyint(1) NOT NULL DEFAULT 0,
  `REQUIERE_VENCIMIENTO` tinyint(1) NOT NULL DEFAULT 0,
  `APLICA_ASPIRANTE` tinyint(1) NOT NULL DEFAULT 0,
  `APLICA_CONTRATACION` tinyint(1) NOT NULL DEFAULT 1,
  `APLICA_RETIRO` tinyint(1) NOT NULL DEFAULT 0,
  `ACTIVO` tinyint(1) NOT NULL DEFAULT 1,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_TIPO_DOCUMENTO_LABORAL`),
  UNIQUE KEY `UQ_BBF_TIPOS_DOCUMENTO_LABORAL_NOMBRE` (`NOMBRE`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_tipos_documento_laboral`
--

LOCK TABLES `bbf_tipos_documento_laboral` WRITE;
/*!40000 ALTER TABLE `bbf_tipos_documento_laboral` DISABLE KEYS */;
INSERT INTO `bbf_tipos_documento_laboral` VALUES (1,'Copia de documento de identidad','Documento de identificación del empleado',1,0,1,1,0,1,'2026-06-23 22:40:44','2026-06-24 13:31:10'),(2,'Hoja de vida','Hoja de vida del empleado',1,0,1,1,0,1,'2026-06-23 22:40:44','2026-06-24 13:31:10'),(3,'Contrato firmado','Contrato laboral firmado por las partes',1,1,0,1,0,1,'2026-06-23 22:40:44',NULL),(4,'Afiliación EPS','Soporte de afiliación a EPS',1,0,0,1,0,1,'2026-06-23 22:40:44',NULL),(5,'Afiliación ARL','Soporte de afiliación a ARL',1,0,0,1,0,1,'2026-06-23 22:40:44',NULL),(6,'Afiliación pensión','Soporte de afiliación a fondo de pensión',1,0,0,1,0,1,'2026-06-23 22:40:44',NULL),(7,'Afiliación caja de compensación','Soporte de afiliación a caja de compensación',1,0,0,1,0,1,'2026-06-23 22:40:44',NULL),(8,'Afiliación cesantías','Soporte de afiliación a fondo de cesantías',0,0,0,1,0,1,'2026-06-23 22:40:44',NULL),(9,'Examen médico de ingreso','Soporte del examen médico ocupacional de ingreso',1,1,0,1,0,1,'2026-06-23 22:40:44',NULL),(10,'Certificado bancario','Certificado de cuenta bancaria para pagos',0,0,0,1,0,1,'2026-06-23 22:40:44',NULL),(11,'Certificados de estudio','Soportes académicos del empleado',0,0,1,1,0,1,'2026-06-23 22:40:44','2026-06-24 13:31:10'),(12,'Certificados laborales anteriores','Certificados de experiencia laboral previa',0,0,1,1,0,1,'2026-06-23 22:40:44','2026-06-24 13:31:10'),(13,'RUT','Registro Único Tributario, si aplica',0,0,0,1,0,1,'2026-06-23 22:40:44',NULL),(14,'Otro','Otro documento laboral',0,0,0,1,0,1,'2026-06-23 22:40:44',NULL),(15,'Certificado familiar o personal','Certificados relacionados con hijos, matrimonio u otra información familiar o personal requerida por Recursos Humanos',0,0,1,1,0,1,'2026-06-24 13:31:11',NULL),(16,'Contrato de arrendamiento','Soporte del contrato de arrendamiento o documento relacionado con la vivienda del empleado',0,0,0,1,0,1,'2026-07-23 16:39:06',NULL),(17,'Carnet ARL','Carnet o soporte equivalente expedido por la ARL del empleado',0,0,0,1,0,1,'2026-07-23 16:39:06',NULL),(18,'Batería de riesgo psicosocial','Soporte relacionado con la aplicación de la batería de riesgo psicosocial',0,0,0,1,0,1,'2026-07-23 16:39:06',NULL);
/*!40000 ALTER TABLE `bbf_tipos_documento_laboral` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_tipos_dotacion`
--

DROP TABLE IF EXISTS `bbf_tipos_dotacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_tipos_dotacion` (
  `ID_TIPO_DOTACION` int(11) NOT NULL AUTO_INCREMENT,
  `NOMBRE` varchar(120) NOT NULL,
  `DESCRIPCION` varchar(250) DEFAULT NULL,
  `REQUIERE_TALLA` tinyint(1) NOT NULL DEFAULT 1,
  `ACTIVO` tinyint(1) NOT NULL DEFAULT 1,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_TIPO_DOTACION`),
  UNIQUE KEY `UQ_BBF_TIPOS_DOTACION_NOMBRE` (`NOMBRE`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_tipos_dotacion`
--

LOCK TABLES `bbf_tipos_dotacion` WRITE;
/*!40000 ALTER TABLE `bbf_tipos_dotacion` DISABLE KEYS */;
INSERT INTO `bbf_tipos_dotacion` VALUES (1,'Camisa','Camisa o camiseta institucional',1,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(2,'Pantalón','Pantalón de dotación laboral',1,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(3,'Calzado','Botas o zapatos de trabajo',1,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(4,'Guantes','Guantes de protección',1,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(5,'Gorra','Gorra institucional o de protección solar',1,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(6,'Delantal','Delantal o prenda de protección',1,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(7,'Chaqueta','Chaqueta o buzo de dotación',1,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(9,'Overol','Overol de dotación laboral',1,1,'2026-07-23 16:39:06',NULL),(10,'Bata','Bata de dotación laboral',1,1,'2026-07-24 09:36:22',NULL),(11,'Elemento sin talla','Familia técnica para artículos de dotación que no requieren talla.',0,1,'2026-08-03 12:00:55',NULL);
/*!40000 ALTER TABLE `bbf_tipos_dotacion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_tipos_examen_medico`
--

DROP TABLE IF EXISTS `bbf_tipos_examen_medico`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_tipos_examen_medico` (
  `ID_TIPO_EXAMEN_MEDICO` int(11) NOT NULL AUTO_INCREMENT,
  `NOMBRE` varchar(120) NOT NULL,
  `DESCRIPCION` varchar(500) DEFAULT NULL,
  `ACTIVO` tinyint(1) NOT NULL DEFAULT 1,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_TIPO_EXAMEN_MEDICO`),
  UNIQUE KEY `UQ_BBF_TIPOS_EXAMEN_MEDICO_NOMBRE` (`NOMBRE`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_tipos_examen_medico`
--

LOCK TABLES `bbf_tipos_examen_medico` WRITE;
/*!40000 ALTER TABLE `bbf_tipos_examen_medico` DISABLE KEYS */;
INSERT INTO `bbf_tipos_examen_medico` VALUES (1,'Ingreso','Examen médico ocupacional de ingreso',1,'2026-06-23 22:40:44',NULL),(2,'Periódico','Examen médico ocupacional periódico',1,'2026-06-23 22:40:44',NULL),(3,'Retiro','Examen médico ocupacional de retiro',1,'2026-06-23 22:40:44',NULL),(4,'Reintegro','Examen médico por reintegro laboral',1,'2026-06-23 22:40:44',NULL),(5,'Post incapacidad','Examen médico posterior a incapacidad',1,'2026-06-23 22:40:44',NULL);
/*!40000 ALTER TABLE `bbf_tipos_examen_medico` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_usuario_password_historial`
--

DROP TABLE IF EXISTS `bbf_usuario_password_historial`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_usuario_password_historial` (
  `ID_PASSWORD_HISTORIAL` bigint(20) NOT NULL AUTO_INCREMENT,
  `ID_USUARIO` int(11) NOT NULL,
  `PASSWORD_HASH` varchar(255) NOT NULL,
  `FECHA_CAMBIO` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`ID_PASSWORD_HISTORIAL`),
  KEY `FK_BBF_PASSWORD_HISTORIAL_USUARIO` (`ID_USUARIO`),
  CONSTRAINT `FK_BBF_PASSWORD_HISTORIAL_USUARIO` FOREIGN KEY (`ID_USUARIO`) REFERENCES `bbf_usuarios` (`ID_USUARIO`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_usuario_password_historial`
--

LOCK TABLES `bbf_usuario_password_historial` WRITE;
/*!40000 ALTER TABLE `bbf_usuario_password_historial` DISABLE KEYS */;
INSERT INTO `bbf_usuario_password_historial` VALUES (3,15,'$2y$12$/tAVo2a6otxziZB4xxt83Otj6Fd78trS9Td7cAtlnxHa5UWFLrCXC','2026-07-23 08:52:11');
/*!40000 ALTER TABLE `bbf_usuario_password_historial` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_usuario_password_reset`
--

DROP TABLE IF EXISTS `bbf_usuario_password_reset`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_usuario_password_reset` (
  `ID_RESET` bigint(20) NOT NULL AUTO_INCREMENT,
  `ID_USUARIO` int(11) NOT NULL,
  `TOKEN_HASH` varchar(255) NOT NULL,
  `FECHA_CREACION` datetime NOT NULL DEFAULT current_timestamp(),
  `FECHA_EXPIRACION` datetime NOT NULL,
  `FECHA_USO` datetime DEFAULT NULL,
  `USADO` tinyint(1) NOT NULL DEFAULT 0,
  `IP_SOLICITUD` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`ID_RESET`),
  KEY `FK_BBF_PASSWORD_RESET_USUARIO` (`ID_USUARIO`),
  CONSTRAINT `FK_BBF_PASSWORD_RESET_USUARIO` FOREIGN KEY (`ID_USUARIO`) REFERENCES `bbf_usuarios` (`ID_USUARIO`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_usuario_password_reset`
--

LOCK TABLES `bbf_usuario_password_reset` WRITE;
/*!40000 ALTER TABLE `bbf_usuario_password_reset` DISABLE KEYS */;
/*!40000 ALTER TABLE `bbf_usuario_password_reset` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_usuario_roles`
--

DROP TABLE IF EXISTS `bbf_usuario_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_usuario_roles` (
  `ID_USUARIO_ROL` int(11) NOT NULL AUTO_INCREMENT,
  `ID_USUARIO` int(11) NOT NULL,
  `ID_ROL` int(11) NOT NULL,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`ID_USUARIO_ROL`),
  UNIQUE KEY `UQ_BBF_USUARIO_ROLES` (`ID_USUARIO`,`ID_ROL`),
  KEY `FK_BBF_USUARIO_ROLES_ROL` (`ID_ROL`),
  CONSTRAINT `FK_BBF_USUARIO_ROLES_ROL` FOREIGN KEY (`ID_ROL`) REFERENCES `bbf_roles` (`ID_ROL`) ON DELETE CASCADE,
  CONSTRAINT `FK_BBF_USUARIO_ROLES_USUARIO` FOREIGN KEY (`ID_USUARIO`) REFERENCES `bbf_usuarios` (`ID_USUARIO`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_usuario_roles`
--

LOCK TABLES `bbf_usuario_roles` WRITE;
/*!40000 ALTER TABLE `bbf_usuario_roles` DISABLE KEYS */;
INSERT INTO `bbf_usuario_roles` VALUES (10,15,1,'2026-07-23 08:48:46');
/*!40000 ALTER TABLE `bbf_usuario_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_usuario_sesiones`
--

DROP TABLE IF EXISTS `bbf_usuario_sesiones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_usuario_sesiones` (
  `ID_SESION` bigint(20) NOT NULL AUTO_INCREMENT,
  `ID_USUARIO` int(11) NOT NULL,
  `REFRESH_TOKEN_HASH` varchar(255) NOT NULL,
  `IP_ORIGEN` varchar(50) DEFAULT NULL,
  `USER_AGENT` varchar(500) DEFAULT NULL,
  `FECHA_CREACION` datetime NOT NULL DEFAULT current_timestamp(),
  `FECHA_EXPIRACION` datetime NOT NULL,
  `FECHA_REVOCACION` datetime DEFAULT NULL,
  `ACTIVO` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`ID_SESION`),
  KEY `FK_BBF_USUARIO_SESIONES_USUARIO` (`ID_USUARIO`),
  CONSTRAINT `FK_BBF_USUARIO_SESIONES_USUARIO` FOREIGN KEY (`ID_USUARIO`) REFERENCES `bbf_usuarios` (`ID_USUARIO`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_usuario_sesiones`
--

LOCK TABLES `bbf_usuario_sesiones` WRITE;
/*!40000 ALTER TABLE `bbf_usuario_sesiones` DISABLE KEYS */;
INSERT INTO `bbf_usuario_sesiones` VALUES (1,15,'1f712f2b5a3b05568a9664297c8096ac6b564f1af47b79199cadfde814ffe638','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-11 10:52:40','2026-08-18 15:52:40',NULL,1);
/*!40000 ALTER TABLE `bbf_usuario_sesiones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbf_usuarios`
--

DROP TABLE IF EXISTS `bbf_usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_usuarios` (
  `ID_USUARIO` int(11) NOT NULL AUTO_INCREMENT,
  `ID_EMPLEADO` int(11) DEFAULT NULL,
  `NOMBRE_USUARIO` varchar(100) NOT NULL,
  `CORREO` varchar(150) NOT NULL,
  `PASSWORD_HASH` varchar(255) NOT NULL,
  `TIPO_USUARIO` enum('EMPLEADO','PERSONAL_AUTORIZADO','ADMIN') NOT NULL DEFAULT 'EMPLEADO',
  `TIPO_AUTENTICACION` enum('LOCAL','DOMINIO_EMPRESA') NOT NULL DEFAULT 'LOCAL',
  `REQUIERE_CAMBIO_PASSWORD` tinyint(1) NOT NULL DEFAULT 1,
  `CORREO_VERIFICADO` tinyint(1) NOT NULL DEFAULT 0,
  `ESTADO` enum('ACTIVO','INACTIVO','BLOQUEADO','ELIMINADO') NOT NULL DEFAULT 'ACTIVO',
  `INTENTOS_FALLIDOS` int(11) NOT NULL DEFAULT 0,
  `FECHA_BLOQUEO` datetime DEFAULT NULL,
  `ULTIMO_LOGIN` datetime DEFAULT NULL,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_USUARIO`),
  UNIQUE KEY `UQ_BBF_USUARIOS_NOMBRE_USUARIO` (`NOMBRE_USUARIO`),
  UNIQUE KEY `UQ_BBF_USUARIOS_CORREO` (`CORREO`),
  KEY `FK_BBF_USUARIOS_EMPLEADO` (`ID_EMPLEADO`),
  CONSTRAINT `FK_BBF_USUARIOS_EMPLEADO` FOREIGN KEY (`ID_EMPLEADO`) REFERENCES `bbf_empleados` (`ID_EMPLEADO`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_usuarios`
--

LOCK TABLES `bbf_usuarios` WRITE;
/*!40000 ALTER TABLE `bbf_usuarios` DISABLE KEYS */;
INSERT INTO `bbf_usuarios` VALUES (15,NULL,'ADM','AD@Email.com','$2y$12$VWmMET61XwlqcXbHqamNI.RRPI.sig6NQ6she3rd4OupJNozHdDqm','ADMIN','LOCAL',0,0,'ACTIVO',0,NULL,'2026-08-11 10:52:40','2026-07-23 08:48:05','2026-08-11 10:52:40');
/*!40000 ALTER TABLE `bbf_usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'bbf_administrativo'
--
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_AREAS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_AREAS_LISTAR`(
    IN P_SOLO_ACTIVOS TINYINT
)
BEGIN
    SELECT
        ID_AREA,
        NOMBRE,
        DESCRIPCION,
        ACTIVO,
        CREATED_AT,
        UPDATED_AT
    FROM bbf_areas
    WHERE P_SOLO_ACTIVOS = 0 OR ACTIVO = 1
    ORDER BY NOMBRE ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_ASPIRANTES_ACTUALIZAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_ASPIRANTES_ACTUALIZAR`(
    IN P_ID_ASPIRANTE INT,
    IN P_ID_TIPO_DOCUMENTO INT,
    IN P_NUMERO_DOCUMENTO VARCHAR(50),
    IN P_NOMBRES VARCHAR(150),
    IN P_APELLIDOS VARCHAR(150),
    IN P_CORREO VARCHAR(150),
    IN P_TELEFONO VARCHAR(50),
    IN P_DIRECCION VARCHAR(250),
    IN P_FECHA_NACIMIENTO DATE,

    IN P_ID_DEPARTAMENTO_NACIMIENTO INT,
    IN P_ID_MUNICIPIO_NACIMIENTO INT,

    IN P_NACIONALIDAD VARCHAR(100),

    IN P_ID_DEPARTAMENTO_RESIDENCIA INT,
    IN P_ID_MUNICIPIO_RESIDENCIA INT,

    IN P_ESTADO_CIVIL VARCHAR(50),
    IN P_NIVEL_EDUCATIVO VARCHAR(50),
    IN P_PERSONAS_A_CARGO INT,
    IN P_NUMERO_HIJOS INT,
    IN P_ID_AREA_ASPIRA INT,
    IN P_ID_CARGO_ASPIRA INT,
    IN P_OBSERVACIONES TEXT
)
BEGIN
    DECLARE V_EXISTE INT DEFAULT 0;

    DECLARE V_DEP_NAC VARCHAR(150) DEFAULT NULL;
    DECLARE V_MUN_NAC VARCHAR(150) DEFAULT NULL;
    DECLARE V_DEP_RES VARCHAR(150) DEFAULT NULL;
    DECLARE V_MUN_RES VARCHAR(150) DEFAULT NULL;


    -- --------------------------------------------------------
    -- Aspirante existente
    -- --------------------------------------------------------

    SELECT COUNT(*)
    INTO V_EXISTE
    FROM bbf_aspirantes
    WHERE ID_ASPIRANTE = P_ID_ASPIRANTE
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_EXISTE = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'El aspirante no existe o fue eliminado.';
    END IF;


    -- Recuperar textos históricos por compatibilidad.
    SELECT
        DEPARTAMENTO_NACIMIENTO,
        LUGAR_NACIMIENTO,
        DEPARTAMENTO_RESIDENCIA,
        CIUDAD_RESIDENCIA
    INTO
        V_DEP_NAC,
        V_MUN_NAC,
        V_DEP_RES,
        V_MUN_RES
    FROM bbf_aspirantes
    WHERE ID_ASPIRANTE = P_ID_ASPIRANTE
    LIMIT 1;


    -- --------------------------------------------------------
    -- Documento duplicado
    -- --------------------------------------------------------

    SELECT COUNT(*)
    INTO V_EXISTE
    FROM bbf_aspirantes
    WHERE NUMERO_DOCUMENTO = P_NUMERO_DOCUMENTO
      AND ID_ASPIRANTE <> P_ID_ASPIRANTE
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_EXISTE > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Ya existe otro aspirante activo con ese número de documento.';
    END IF;


    -- --------------------------------------------------------
    -- Catálogos
    -- --------------------------------------------------------

    IF P_ESTADO_CIVIL IS NOT NULL
       AND P_ESTADO_CIVIL NOT IN (
           'SOLTERO',
           'CASADO',
           'UNION_LIBRE',
           'SEPARADO',
           'DIVORCIADO',
           'VIUDO',
           'OTRO'
       ) THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Estado civil no válido.';

    END IF;


    IF P_NIVEL_EDUCATIVO IS NOT NULL
       AND P_NIVEL_EDUCATIVO NOT IN (
           'PRIMARIA',
           'BACHILLER',
           'TECNICO',
           'TECNOLOGO',
           'PROFESIONAL',
           'POSGRADO',
           'NINGUNO',
           'OTRO'
       ) THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nivel educativo no válido.';

    END IF;


    -- --------------------------------------------------------
    -- Nacimiento
    -- --------------------------------------------------------

    IF P_ID_DEPARTAMENTO_NACIMIENTO IS NOT NULL
       OR P_ID_MUNICIPIO_NACIMIENTO IS NOT NULL THEN

        IF P_ID_DEPARTAMENTO_NACIMIENTO IS NULL
           OR P_ID_MUNICIPIO_NACIMIENTO IS NULL THEN

            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Departamento y municipio de nacimiento deben enviarse juntos.';

        END IF;


        SELECT COUNT(*)
        INTO V_EXISTE
        FROM bbf_municipios M
        INNER JOIN bbf_departamentos D
            ON D.ID_DEPARTAMENTO = M.ID_DEPARTAMENTO
        WHERE D.ID_DEPARTAMENTO =
                  P_ID_DEPARTAMENTO_NACIMIENTO
          AND M.ID_MUNICIPIO =
                  P_ID_MUNICIPIO_NACIMIENTO
          AND D.ACTIVO = 1
          AND M.ACTIVO = 1;

        IF V_EXISTE = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'El municipio de nacimiento no pertenece al departamento seleccionado.';
        END IF;


        SELECT
            D.NOMBRE,
            M.NOMBRE
        INTO
            V_DEP_NAC,
            V_MUN_NAC
        FROM bbf_municipios M
        INNER JOIN bbf_departamentos D
            ON D.ID_DEPARTAMENTO = M.ID_DEPARTAMENTO
        WHERE D.ID_DEPARTAMENTO =
                  P_ID_DEPARTAMENTO_NACIMIENTO
          AND M.ID_MUNICIPIO =
                  P_ID_MUNICIPIO_NACIMIENTO
        LIMIT 1;

    END IF;


    -- --------------------------------------------------------
    -- Residencia
    -- --------------------------------------------------------

    IF P_ID_DEPARTAMENTO_RESIDENCIA IS NOT NULL
       OR P_ID_MUNICIPIO_RESIDENCIA IS NOT NULL THEN

        IF P_ID_DEPARTAMENTO_RESIDENCIA IS NULL
           OR P_ID_MUNICIPIO_RESIDENCIA IS NULL THEN

            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Departamento y municipio de residencia deben enviarse juntos.';

        END IF;


        SELECT COUNT(*)
        INTO V_EXISTE
        FROM bbf_municipios M
        INNER JOIN bbf_departamentos D
            ON D.ID_DEPARTAMENTO = M.ID_DEPARTAMENTO
        WHERE D.ID_DEPARTAMENTO =
                  P_ID_DEPARTAMENTO_RESIDENCIA
          AND M.ID_MUNICIPIO =
                  P_ID_MUNICIPIO_RESIDENCIA
          AND D.ACTIVO = 1
          AND M.ACTIVO = 1;

        IF V_EXISTE = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'El municipio de residencia no pertenece al departamento seleccionado.';
        END IF;


        SELECT
            D.NOMBRE,
            M.NOMBRE
        INTO
            V_DEP_RES,
            V_MUN_RES
        FROM bbf_municipios M
        INNER JOIN bbf_departamentos D
            ON D.ID_DEPARTAMENTO = M.ID_DEPARTAMENTO
        WHERE D.ID_DEPARTAMENTO =
                  P_ID_DEPARTAMENTO_RESIDENCIA
          AND M.ID_MUNICIPIO =
                  P_ID_MUNICIPIO_RESIDENCIA
        LIMIT 1;

    END IF;


    UPDATE bbf_aspirantes
    SET
        ID_TIPO_DOCUMENTO = P_ID_TIPO_DOCUMENTO,
        NUMERO_DOCUMENTO = P_NUMERO_DOCUMENTO,
        NOMBRES = P_NOMBRES,
        APELLIDOS = P_APELLIDOS,
        CORREO = P_CORREO,
        TELEFONO = P_TELEFONO,
        DIRECCION = P_DIRECCION,
        FECHA_NACIMIENTO = P_FECHA_NACIMIENTO,

        ID_DEPARTAMENTO_NACIMIENTO =
            P_ID_DEPARTAMENTO_NACIMIENTO,

        ID_MUNICIPIO_NACIMIENTO =
            P_ID_MUNICIPIO_NACIMIENTO,

        LUGAR_NACIMIENTO = V_MUN_NAC,
        DEPARTAMENTO_NACIMIENTO = V_DEP_NAC,

        NACIONALIDAD = P_NACIONALIDAD,

        ID_DEPARTAMENTO_RESIDENCIA =
            P_ID_DEPARTAMENTO_RESIDENCIA,

        ID_MUNICIPIO_RESIDENCIA =
            P_ID_MUNICIPIO_RESIDENCIA,

        CIUDAD_RESIDENCIA = V_MUN_RES,
        DEPARTAMENTO_RESIDENCIA = V_DEP_RES,

        ESTADO_CIVIL = P_ESTADO_CIVIL,
        NIVEL_EDUCATIVO = P_NIVEL_EDUCATIVO,
        PERSONAS_A_CARGO = IFNULL(P_PERSONAS_A_CARGO, 0),
        NUMERO_HIJOS = IFNULL(P_NUMERO_HIJOS, 0),
        ID_AREA_ASPIRA = P_ID_AREA_ASPIRA,
        ID_CARGO_ASPIRA = P_ID_CARGO_ASPIRA,
        OBSERVACIONES = P_OBSERVACIONES,
        UPDATED_AT = CURRENT_TIMESTAMP

    WHERE ID_ASPIRANTE = P_ID_ASPIRANTE;


    SELECT P_ID_ASPIRANTE AS ID_ASPIRANTE;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_ASPIRANTES_CAMBIAR_ESTADO` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_ASPIRANTES_CAMBIAR_ESTADO`(
    IN P_ID_ASPIRANTE INT,
    IN P_ESTADO_NUEVO VARCHAR(50),
    IN P_OBSERVACIONES TEXT,
    IN P_ID_USUARIO INT
)
BEGIN
    DECLARE V_ESTADO_ANTERIOR VARCHAR(50);
    DECLARE V_EXISTE INT DEFAULT 0;

    IF P_ESTADO_NUEVO NOT IN (
        'REGISTRADO',
        'EN_REVISION',
        'APROBADO_CONTRATACION',
        'RECHAZADO',
        'CONVERTIDO_EMPLEADO',
        'CANCELADO'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Estado de aspirante no válido.';
    END IF;

    SELECT COUNT(*)
    INTO V_EXISTE
    FROM bbf_aspirantes
    WHERE ID_ASPIRANTE = P_ID_ASPIRANTE
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_EXISTE = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El aspirante no existe o fue eliminado.';
    END IF;

    SELECT ESTADO_ASPIRANTE
    INTO V_ESTADO_ANTERIOR
    FROM bbf_aspirantes
    WHERE ID_ASPIRANTE = P_ID_ASPIRANTE
    LIMIT 1;

    IF V_ESTADO_ANTERIOR = 'CONVERTIDO_EMPLEADO' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede cambiar el estado de un aspirante ya convertido en empleado.';
    END IF;

    UPDATE bbf_aspirantes
    SET
        ESTADO_ASPIRANTE = P_ESTADO_NUEVO,
        UPDATED_AT = CURRENT_TIMESTAMP
    WHERE ID_ASPIRANTE = P_ID_ASPIRANTE;

    INSERT INTO bbf_aspirante_estado_historial (
        ID_ASPIRANTE,
        ESTADO_ANTERIOR,
        ESTADO_NUEVO,
        OBSERVACIONES,
        ID_USUARIO_CAMBIO
    )
    VALUES (
        P_ID_ASPIRANTE,
        V_ESTADO_ANTERIOR,
        P_ESTADO_NUEVO,
        P_OBSERVACIONES,
        P_ID_USUARIO
    );

    SELECT
        P_ID_ASPIRANTE AS ID_ASPIRANTE,
        V_ESTADO_ANTERIOR AS ESTADO_ANTERIOR,
        P_ESTADO_NUEVO AS ESTADO_NUEVO;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_ASPIRANTES_CONVERTIR_EMPLEADO` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_ASPIRANTES_CONVERTIR_EMPLEADO`(
    IN P_ID_ASPIRANTE INT,
    IN P_ID_TIPO_CONTRATO INT,
    IN P_FECHA_INGRESO DATE,
    IN P_ID_USUARIO INT,
    IN P_OBSERVACIONES TEXT
)
BEGIN
    DECLARE V_EXISTE INT DEFAULT 0;
    DECLARE V_ESTADO VARCHAR(50);
    DECLARE V_ID_EMPLEADO_GENERADO INT;
    DECLARE V_NUMERO_DOCUMENTO VARCHAR(50);
    DECLARE V_ID_EMPLEADO_NUEVO INT;
    DECLARE V_ESTADO_ANTERIOR VARCHAR(50);


    -- --------------------------------------------------------
    -- Validar aspirante
    -- --------------------------------------------------------

    SELECT COUNT(*)
    INTO V_EXISTE
    FROM bbf_aspirantes
    WHERE ID_ASPIRANTE = P_ID_ASPIRANTE
      AND IFNULL(ELIMINADO, 0) = 0;


    IF V_EXISTE = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'El aspirante no existe o fue eliminado.';
    END IF;


    SELECT
        ESTADO_ASPIRANTE,
        ID_EMPLEADO_GENERADO,
        NUMERO_DOCUMENTO
    INTO
        V_ESTADO,
        V_ID_EMPLEADO_GENERADO,
        V_NUMERO_DOCUMENTO
    FROM bbf_aspirantes
    WHERE ID_ASPIRANTE = P_ID_ASPIRANTE
    LIMIT 1;


    -- --------------------------------------------------------
    -- Validar estado
    -- --------------------------------------------------------

    IF V_ESTADO <> 'APROBADO_CONTRATACION' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'El aspirante debe estar en estado APROBADO_CONTRATACION para convertirse en empleado.';
    END IF;


    IF V_ID_EMPLEADO_GENERADO IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'El aspirante ya fue convertido en empleado.';
    END IF;


    -- --------------------------------------------------------
    -- Validar empleado existente
    -- --------------------------------------------------------

    SELECT COUNT(*)
    INTO V_EXISTE
    FROM bbf_empleados
    WHERE NUMERO_DOCUMENTO = V_NUMERO_DOCUMENTO
      AND IFNULL(ELIMINADO, 0) = 0;


    IF V_EXISTE > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Ya existe un empleado activo con el documento del aspirante.';
    END IF;


    -- --------------------------------------------------------
    -- Crear empleado
    -- --------------------------------------------------------

    INSERT INTO bbf_empleados (
        ID_ASPIRANTE_ORIGEN,
        ID_TIPO_DOCUMENTO,
        NUMERO_DOCUMENTO,
        NOMBRES,
        APELLIDOS,
        CORREO,
        TELEFONO,
        ID_AREA,
        ID_CARGO,
        ID_TIPO_CONTRATO,
        FECHA_INGRESO,
        ESTADO_EMPLEADO,
        OBSERVACIONES
    )
    SELECT
        ASP.ID_ASPIRANTE,
        ASP.ID_TIPO_DOCUMENTO,
        ASP.NUMERO_DOCUMENTO,
        ASP.NOMBRES,
        ASP.APELLIDOS,
        ASP.CORREO,
        ASP.TELEFONO,
        ASP.ID_AREA_ASPIRA,
        ASP.ID_CARGO_ASPIRA,
        P_ID_TIPO_CONTRATO,
        IFNULL(P_FECHA_INGRESO, CURRENT_DATE()),
        'ACTIVO',

        CONCAT(
            'Empleado generado desde aspirante. ',
            IFNULL(P_OBSERVACIONES, '')
        )

    FROM bbf_aspirantes ASP
    WHERE ASP.ID_ASPIRANTE = P_ID_ASPIRANTE;


    SET V_ID_EMPLEADO_NUEVO = LAST_INSERT_ID();


    -- --------------------------------------------------------
    -- Migrar documentos del aspirante al empleado
    -- --------------------------------------------------------

    INSERT INTO bbf_empleado_documentos (
        ID_EMPLEADO,
        ID_TIPO_DOCUMENTO_LABORAL,
        NOMBRE_ARCHIVO,
        ARCHIVO_URL,
        ESTADO_DOCUMENTO,
        ELIMINADO,
        FECHA_CARGA
    )
    SELECT
        V_ID_EMPLEADO_NUEVO,
        AD.ID_TIPO_DOCUMENTO_LABORAL,
        AD.NOMBRE_ARCHIVO,
        AD.ARCHIVO_URL,
        AD.ESTADO_DOCUMENTO,
        IFNULL(AD.ELIMINADO, 0),
        IFNULL(AD.CREATED_AT, CURRENT_TIMESTAMP)

    FROM bbf_aspirante_documentos AD

    WHERE AD.ID_ASPIRANTE = P_ID_ASPIRANTE
      AND IFNULL(AD.ELIMINADO, 0) = 0

      AND NOT EXISTS (
          SELECT 1
          FROM bbf_empleado_documentos ED
          WHERE ED.ID_EMPLEADO = V_ID_EMPLEADO_NUEVO
            AND ED.ID_TIPO_DOCUMENTO_LABORAL =
                AD.ID_TIPO_DOCUMENTO_LABORAL
            AND IFNULL(ED.ELIMINADO, 0) = 0
      );


    -- --------------------------------------------------------
    -- Crear ficha precargada
    -- --------------------------------------------------------

    INSERT INTO bbf_empleado_ficha_ingreso (
        ID_EMPLEADO,

        FECHA_NACIMIENTO,

        ID_DEPARTAMENTO_NACIMIENTO,
        ID_MUNICIPIO_NACIMIENTO,

        LUGAR_NACIMIENTO,
        DEPARTAMENTO_NACIMIENTO,

        NACIONALIDAD,

        ID_DEPARTAMENTO_RESIDENCIA,
        ID_MUNICIPIO_RESIDENCIA,

        CIUDAD_RESIDENCIA,
        DEPARTAMENTO_RESIDENCIA,

        DIRECCION_RESIDENCIA,
        TELEFONO_ALTERNO,
        CORREO_PERSONAL,

        ESTADO_CIVIL,
        NIVEL_EDUCATIVO,
        PERSONAS_A_CARGO,
        NUMERO_HIJOS,

        ESTADO_FICHA,
        OBSERVACIONES
    )
    SELECT
        V_ID_EMPLEADO_NUEVO,

        ASP.FECHA_NACIMIENTO,

        ASP.ID_DEPARTAMENTO_NACIMIENTO,
        ASP.ID_MUNICIPIO_NACIMIENTO,

        ASP.LUGAR_NACIMIENTO,
        ASP.DEPARTAMENTO_NACIMIENTO,

        ASP.NACIONALIDAD,

        ASP.ID_DEPARTAMENTO_RESIDENCIA,
        ASP.ID_MUNICIPIO_RESIDENCIA,

        ASP.CIUDAD_RESIDENCIA,
        ASP.DEPARTAMENTO_RESIDENCIA,

        ASP.DIRECCION,
        ASP.TELEFONO,
        ASP.CORREO,

        ASP.ESTADO_CIVIL,
        ASP.NIVEL_EDUCATIVO,

        IFNULL(ASP.PERSONAS_A_CARGO, 0),
        IFNULL(ASP.NUMERO_HIJOS, 0),

        'INCOMPLETA',

        CONCAT(
            'Ficha creada automáticamente desde aspirante. ',
            IFNULL(ASP.OBSERVACIONES, '')
        )

    FROM bbf_aspirantes ASP
    WHERE ASP.ID_ASPIRANTE = P_ID_ASPIRANTE;


    -- --------------------------------------------------------
    -- Actualizar aspirante
    -- --------------------------------------------------------

    SET V_ESTADO_ANTERIOR = V_ESTADO;


    UPDATE bbf_aspirantes
    SET
        ESTADO_ASPIRANTE = 'CONVERTIDO_EMPLEADO',
        ID_EMPLEADO_GENERADO = V_ID_EMPLEADO_NUEVO,
        UPDATED_AT = CURRENT_TIMESTAMP
    WHERE ID_ASPIRANTE = P_ID_ASPIRANTE;


    -- --------------------------------------------------------
    -- Registrar historial
    -- --------------------------------------------------------

    INSERT INTO bbf_aspirante_estado_historial (
        ID_ASPIRANTE,
        ESTADO_ANTERIOR,
        ESTADO_NUEVO,
        OBSERVACIONES,
        ID_USUARIO_CAMBIO
    )
    VALUES (
        P_ID_ASPIRANTE,
        V_ESTADO_ANTERIOR,
        'CONVERTIDO_EMPLEADO',
        IFNULL(
            P_OBSERVACIONES,
            'Aspirante convertido en empleado'
        ),
        P_ID_USUARIO
    );


    -- --------------------------------------------------------
    -- Resultado
    -- --------------------------------------------------------

    SELECT
        P_ID_ASPIRANTE AS ID_ASPIRANTE,
        V_ID_EMPLEADO_NUEVO AS ID_EMPLEADO,
        'CONVERTIDO_EMPLEADO' AS ESTADO_ASPIRANTE,
        'INCOMPLETA' AS ESTADO_FICHA;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_ASPIRANTES_CREAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_ASPIRANTES_CREAR`(
    IN P_ID_TIPO_DOCUMENTO INT,
    IN P_NUMERO_DOCUMENTO VARCHAR(50),
    IN P_NOMBRES VARCHAR(150),
    IN P_APELLIDOS VARCHAR(150),
    IN P_CORREO VARCHAR(150),
    IN P_TELEFONO VARCHAR(50),
    IN P_DIRECCION VARCHAR(250),
    IN P_FECHA_NACIMIENTO DATE,

    IN P_ID_DEPARTAMENTO_NACIMIENTO INT,
    IN P_ID_MUNICIPIO_NACIMIENTO INT,

    IN P_NACIONALIDAD VARCHAR(100),

    IN P_ID_DEPARTAMENTO_RESIDENCIA INT,
    IN P_ID_MUNICIPIO_RESIDENCIA INT,

    IN P_ESTADO_CIVIL VARCHAR(50),
    IN P_NIVEL_EDUCATIVO VARCHAR(50),
    IN P_PERSONAS_A_CARGO INT,
    IN P_NUMERO_HIJOS INT,
    IN P_ID_AREA_ASPIRA INT,
    IN P_ID_CARGO_ASPIRA INT,
    IN P_OBSERVACIONES TEXT,
    IN P_ID_USUARIO INT
)
BEGIN
    DECLARE V_ID_ASPIRANTE INT;
    DECLARE V_EXISTE INT DEFAULT 0;

    DECLARE V_DEP_NAC VARCHAR(150) DEFAULT NULL;
    DECLARE V_MUN_NAC VARCHAR(150) DEFAULT NULL;

    DECLARE V_DEP_RES VARCHAR(150) DEFAULT NULL;
    DECLARE V_MUN_RES VARCHAR(150) DEFAULT NULL;


    -- --------------------------------------------------------
    -- Documento duplicado
    -- --------------------------------------------------------

    SELECT COUNT(*)
    INTO V_EXISTE
    FROM bbf_aspirantes
    WHERE NUMERO_DOCUMENTO = P_NUMERO_DOCUMENTO
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_EXISTE > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Ya existe un aspirante activo con ese número de documento.';
    END IF;


    SELECT COUNT(*)
    INTO V_EXISTE
    FROM bbf_empleados
    WHERE NUMERO_DOCUMENTO = P_NUMERO_DOCUMENTO
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_EXISTE > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Ya existe un empleado activo con ese número de documento.';
    END IF;


    -- --------------------------------------------------------
    -- Estado civil
    -- --------------------------------------------------------

    IF P_ESTADO_CIVIL IS NOT NULL
       AND P_ESTADO_CIVIL NOT IN (
           'SOLTERO',
           'CASADO',
           'UNION_LIBRE',
           'SEPARADO',
           'DIVORCIADO',
           'VIUDO',
           'OTRO'
       ) THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Estado civil no válido.';

    END IF;


    -- --------------------------------------------------------
    -- Nivel educativo
    -- --------------------------------------------------------

    IF P_NIVEL_EDUCATIVO IS NOT NULL
       AND P_NIVEL_EDUCATIVO NOT IN (
           'PRIMARIA',
           'BACHILLER',
           'TECNICO',
           'TECNOLOGO',
           'PROFESIONAL',
           'POSGRADO',
           'NINGUNO',
           'OTRO'
       ) THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nivel educativo no válido.';

    END IF;


    -- --------------------------------------------------------
    -- Nacimiento
    -- --------------------------------------------------------

    IF P_ID_DEPARTAMENTO_NACIMIENTO IS NOT NULL
       OR P_ID_MUNICIPIO_NACIMIENTO IS NOT NULL THEN

        IF P_ID_DEPARTAMENTO_NACIMIENTO IS NULL
           OR P_ID_MUNICIPIO_NACIMIENTO IS NULL THEN

            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Departamento y municipio de nacimiento deben enviarse juntos.';

        END IF;


        SELECT COUNT(*)
        INTO V_EXISTE
        FROM bbf_municipios M
        INNER JOIN bbf_departamentos D
            ON D.ID_DEPARTAMENTO = M.ID_DEPARTAMENTO
        WHERE D.ID_DEPARTAMENTO =
                  P_ID_DEPARTAMENTO_NACIMIENTO
          AND M.ID_MUNICIPIO =
                  P_ID_MUNICIPIO_NACIMIENTO
          AND D.ACTIVO = 1
          AND M.ACTIVO = 1;

        IF V_EXISTE = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'El municipio de nacimiento no pertenece al departamento seleccionado.';
        END IF;


        SELECT
            D.NOMBRE,
            M.NOMBRE
        INTO
            V_DEP_NAC,
            V_MUN_NAC
        FROM bbf_municipios M
        INNER JOIN bbf_departamentos D
            ON D.ID_DEPARTAMENTO = M.ID_DEPARTAMENTO
        WHERE D.ID_DEPARTAMENTO =
                  P_ID_DEPARTAMENTO_NACIMIENTO
          AND M.ID_MUNICIPIO =
                  P_ID_MUNICIPIO_NACIMIENTO
        LIMIT 1;

    END IF;


    -- --------------------------------------------------------
    -- Residencia
    -- --------------------------------------------------------

    IF P_ID_DEPARTAMENTO_RESIDENCIA IS NOT NULL
       OR P_ID_MUNICIPIO_RESIDENCIA IS NOT NULL THEN

        IF P_ID_DEPARTAMENTO_RESIDENCIA IS NULL
           OR P_ID_MUNICIPIO_RESIDENCIA IS NULL THEN

            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Departamento y municipio de residencia deben enviarse juntos.';

        END IF;


        SELECT COUNT(*)
        INTO V_EXISTE
        FROM bbf_municipios M
        INNER JOIN bbf_departamentos D
            ON D.ID_DEPARTAMENTO = M.ID_DEPARTAMENTO
        WHERE D.ID_DEPARTAMENTO =
                  P_ID_DEPARTAMENTO_RESIDENCIA
          AND M.ID_MUNICIPIO =
                  P_ID_MUNICIPIO_RESIDENCIA
          AND D.ACTIVO = 1
          AND M.ACTIVO = 1;

        IF V_EXISTE = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'El municipio de residencia no pertenece al departamento seleccionado.';
        END IF;


        SELECT
            D.NOMBRE,
            M.NOMBRE
        INTO
            V_DEP_RES,
            V_MUN_RES
        FROM bbf_municipios M
        INNER JOIN bbf_departamentos D
            ON D.ID_DEPARTAMENTO = M.ID_DEPARTAMENTO
        WHERE D.ID_DEPARTAMENTO =
                  P_ID_DEPARTAMENTO_RESIDENCIA
          AND M.ID_MUNICIPIO =
                  P_ID_MUNICIPIO_RESIDENCIA
        LIMIT 1;

    END IF;


    -- --------------------------------------------------------
    -- Crear aspirante
    -- --------------------------------------------------------

    INSERT INTO bbf_aspirantes (
        ID_TIPO_DOCUMENTO,
        NUMERO_DOCUMENTO,
        NOMBRES,
        APELLIDOS,
        CORREO,
        TELEFONO,
        DIRECCION,
        FECHA_NACIMIENTO,

        ID_DEPARTAMENTO_NACIMIENTO,
        ID_MUNICIPIO_NACIMIENTO,
        LUGAR_NACIMIENTO,
        DEPARTAMENTO_NACIMIENTO,

        NACIONALIDAD,

        ID_DEPARTAMENTO_RESIDENCIA,
        ID_MUNICIPIO_RESIDENCIA,
        CIUDAD_RESIDENCIA,
        DEPARTAMENTO_RESIDENCIA,

        ESTADO_CIVIL,
        NIVEL_EDUCATIVO,
        PERSONAS_A_CARGO,
        NUMERO_HIJOS,
        ID_AREA_ASPIRA,
        ID_CARGO_ASPIRA,
        ESTADO_ASPIRANTE,
        OBSERVACIONES
    )
    VALUES (
        P_ID_TIPO_DOCUMENTO,
        P_NUMERO_DOCUMENTO,
        P_NOMBRES,
        P_APELLIDOS,
        P_CORREO,
        P_TELEFONO,
        P_DIRECCION,
        P_FECHA_NACIMIENTO,

        P_ID_DEPARTAMENTO_NACIMIENTO,
        P_ID_MUNICIPIO_NACIMIENTO,
        V_MUN_NAC,
        V_DEP_NAC,

        P_NACIONALIDAD,

        P_ID_DEPARTAMENTO_RESIDENCIA,
        P_ID_MUNICIPIO_RESIDENCIA,
        V_MUN_RES,
        V_DEP_RES,

        P_ESTADO_CIVIL,
        P_NIVEL_EDUCATIVO,
        IFNULL(P_PERSONAS_A_CARGO, 0),
        IFNULL(P_NUMERO_HIJOS, 0),
        P_ID_AREA_ASPIRA,
        P_ID_CARGO_ASPIRA,
        'REGISTRADO',
        P_OBSERVACIONES
    );


    SET V_ID_ASPIRANTE = LAST_INSERT_ID();


    INSERT INTO bbf_aspirante_estado_historial (
        ID_ASPIRANTE,
        ESTADO_ANTERIOR,
        ESTADO_NUEVO,
        OBSERVACIONES,
        ID_USUARIO_CAMBIO
    )
    VALUES (
        V_ID_ASPIRANTE,
        NULL,
        'REGISTRADO',
        'Registro inicial del aspirante',
        P_ID_USUARIO
    );


    SELECT
        V_ID_ASPIRANTE AS ID_ASPIRANTE,
        'REGISTRADO' AS ESTADO_ASPIRANTE;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_ASPIRANTES_DOCUMENTOS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_ASPIRANTES_DOCUMENTOS_LISTAR`(
    IN P_ID_ASPIRANTE INT
)
BEGIN
    SELECT
        D.ID_ASPIRANTE_DOCUMENTO,
        D.ID_ASPIRANTE,
        D.ID_TIPO_DOCUMENTO_LABORAL,
        TD.NOMBRE AS TIPO_DOCUMENTO_LABORAL,
        TD.OBLIGATORIO,
        TD.REQUIERE_VENCIMIENTO,
        TD.APLICA_ASPIRANTE,

        D.NOMBRE_ARCHIVO,
        D.NOMBRE_ORIGINAL,
        D.ARCHIVO_URL,
        D.ARCHIVO_RUTA,
        D.MIME_TYPE,
        D.PESO_BYTES,
        D.ESTADO_DOCUMENTO,
        D.OBSERVACIONES,

        CASE
            WHEN D.ARCHIVO_RUTA IS NOT NULL AND D.ARCHIVO_RUTA <> '' THEN 'FISICO'
            WHEN D.ARCHIVO_URL IS NOT NULL AND D.ARCHIVO_URL <> '' THEN 'URL'
            ELSE 'SIN_ARCHIVO'
        END AS TIPO_ORIGEN_ARCHIVO,

        D.ID_CARGADO_POR,
        U.NOMBRE_USUARIO AS CARGADO_POR,

        D.CREATED_AT,
        D.UPDATED_AT

    FROM bbf_aspirante_documentos D
    INNER JOIN bbf_tipos_documento_laboral TD
        ON TD.ID_TIPO_DOCUMENTO_LABORAL = D.ID_TIPO_DOCUMENTO_LABORAL
    LEFT JOIN bbf_usuarios U
        ON U.ID_USUARIO = D.ID_CARGADO_POR
    WHERE D.ID_ASPIRANTE = P_ID_ASPIRANTE
      AND IFNULL(D.ELIMINADO, 0) = 0
    ORDER BY TD.OBLIGATORIO DESC, TD.NOMBRE ASC, D.CREATED_AT DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_ASPIRANTES_DOCUMENTO_REGISTRAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_ASPIRANTES_DOCUMENTO_REGISTRAR`(
    IN P_ID_ASPIRANTE INT,
    IN P_ID_TIPO_DOCUMENTO_LABORAL INT,
    IN P_NOMBRE_ARCHIVO VARCHAR(255),
    IN P_NOMBRE_ORIGINAL VARCHAR(255),
    IN P_ARCHIVO_URL VARCHAR(500),
    IN P_ARCHIVO_RUTA VARCHAR(500),
    IN P_MIME_TYPE VARCHAR(100),
    IN P_PESO_BYTES BIGINT,
    IN P_ESTADO_DOCUMENTO VARCHAR(50),
    IN P_OBSERVACIONES TEXT,
    IN P_ID_CARGADO_POR INT
)
BEGIN
    DECLARE V_EXISTE_ASPIRANTE INT DEFAULT 0;
    DECLARE V_APLICA_ASPIRANTE INT DEFAULT 0;
    DECLARE V_ID_DOCUMENTO INT;
    DECLARE V_ESTADO_DOCUMENTO VARCHAR(50);
    DECLARE V_NOMBRE_ARCHIVO VARCHAR(255);

    SELECT COUNT(*)
    INTO V_EXISTE_ASPIRANTE
    FROM bbf_aspirantes
    WHERE ID_ASPIRANTE = P_ID_ASPIRANTE
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_EXISTE_ASPIRANTE = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El aspirante no existe o fue eliminado.';
    END IF;

    SELECT IFNULL(APLICA_ASPIRANTE, 0)
    INTO V_APLICA_ASPIRANTE
    FROM bbf_tipos_documento_laboral
    WHERE ID_TIPO_DOCUMENTO_LABORAL = P_ID_TIPO_DOCUMENTO_LABORAL
      AND ACTIVO = 1
    LIMIT 1;

    IF V_APLICA_ASPIRANTE = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El tipo de documento no aplica para aspirantes.';
    END IF;

    SET V_ESTADO_DOCUMENTO = IFNULL(P_ESTADO_DOCUMENTO, 'CARGADO');

    IF V_ESTADO_DOCUMENTO NOT IN ('PENDIENTE', 'CARGADO', 'VALIDADO', 'RECHAZADO', 'VENCIDO') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Estado de documento no válido.';
    END IF;

    -- Si el estado es CARGADO, debe existir URL externa o ruta física.
    IF V_ESTADO_DOCUMENTO = 'CARGADO'
       AND (P_ARCHIVO_URL IS NULL OR P_ARCHIVO_URL = '')
       AND (P_ARCHIVO_RUTA IS NULL OR P_ARCHIVO_RUTA = '') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Debe registrar una URL externa o cargar un archivo físico.';
    END IF;

    -- Si viene nombre archivo vacío, usar nombre original o texto genérico
    SET V_NOMBRE_ARCHIVO = COALESCE(
        NULLIF(P_NOMBRE_ARCHIVO, ''),
        NULLIF(P_NOMBRE_ORIGINAL, ''),
        'Documento aspirante'
    );

    INSERT INTO bbf_aspirante_documentos (
        ID_ASPIRANTE,
        ID_TIPO_DOCUMENTO_LABORAL,
        NOMBRE_ARCHIVO,
        NOMBRE_ORIGINAL,
        ARCHIVO_URL,
        ARCHIVO_RUTA,
        MIME_TYPE,
        PESO_BYTES,
        ESTADO_DOCUMENTO,
        OBSERVACIONES,
        ID_CARGADO_POR
    )
    VALUES (
        P_ID_ASPIRANTE,
        P_ID_TIPO_DOCUMENTO_LABORAL,
        V_NOMBRE_ARCHIVO,
        P_NOMBRE_ORIGINAL,
        NULLIF(P_ARCHIVO_URL, ''),
        NULLIF(P_ARCHIVO_RUTA, ''),
        P_MIME_TYPE,
        P_PESO_BYTES,
        V_ESTADO_DOCUMENTO,
        P_OBSERVACIONES,
        P_ID_CARGADO_POR
    );

    SET V_ID_DOCUMENTO = LAST_INSERT_ID();

    SELECT
        V_ID_DOCUMENTO AS ID_ASPIRANTE_DOCUMENTO,
        P_ID_ASPIRANTE AS ID_ASPIRANTE,
        V_ESTADO_DOCUMENTO AS ESTADO_DOCUMENTO,
        V_NOMBRE_ARCHIVO AS NOMBRE_ARCHIVO,
        P_NOMBRE_ORIGINAL AS NOMBRE_ORIGINAL,
        NULLIF(P_ARCHIVO_URL, '') AS ARCHIVO_URL,
        NULLIF(P_ARCHIVO_RUTA, '') AS ARCHIVO_RUTA,
        P_MIME_TYPE AS MIME_TYPE,
        P_PESO_BYTES AS PESO_BYTES;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_ASPIRANTES_HISTORIAL_ESTADOS` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_ASPIRANTES_HISTORIAL_ESTADOS`(
    IN P_ID_ASPIRANTE INT
)
BEGIN
    SELECT
        H.ID_HISTORIAL,
        H.ID_ASPIRANTE,
        H.ESTADO_ANTERIOR,
        H.ESTADO_NUEVO,
        H.OBSERVACIONES,
        H.ID_USUARIO_CAMBIO,
        U.NOMBRE_USUARIO AS USUARIO_CAMBIO,
        H.CREATED_AT
    FROM bbf_aspirante_estado_historial H
    LEFT JOIN bbf_usuarios U
        ON U.ID_USUARIO = H.ID_USUARIO_CAMBIO
    WHERE H.ID_ASPIRANTE = P_ID_ASPIRANTE
    ORDER BY H.CREATED_AT DESC, H.ID_HISTORIAL DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_ASPIRANTES_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_ASPIRANTES_LISTAR`(
    IN P_TEXTO_BUSQUEDA VARCHAR(150),
    IN P_ESTADO_ASPIRANTE VARCHAR(50),
    IN P_ID_AREA INT,
    IN P_ID_CARGO INT
)
BEGIN
    SELECT
        A.ID_ASPIRANTE,
        A.ID_TIPO_DOCUMENTO,
        TD.NOMBRE AS TIPO_DOCUMENTO,
        A.NUMERO_DOCUMENTO,
        A.NOMBRES,
        A.APELLIDOS,
        CONCAT(A.NOMBRES, ' ', A.APELLIDOS) AS NOMBRE_COMPLETO,
        A.CORREO,
        A.TELEFONO,
        A.DIRECCION,
        A.FECHA_NACIMIENTO,
        A.LUGAR_NACIMIENTO,
        A.NACIONALIDAD,
        A.ID_AREA_ASPIRA,
        AR.NOMBRE AS AREA_ASPIRA,
        A.ID_CARGO_ASPIRA,
        C.NOMBRE AS CARGO_ASPIRA,
        A.ESTADO_ASPIRANTE,
        A.OBSERVACIONES,
        A.ID_EMPLEADO_GENERADO,
        A.CREATED_AT,
        A.UPDATED_AT,

        COUNT(D.ID_ASPIRANTE_DOCUMENTO) AS TOTAL_DOCUMENTOS,

        SUM(
            CASE
                WHEN D.ESTADO_DOCUMENTO IN ('PENDIENTE', 'RECHAZADO') THEN 1
                ELSE 0
            END
        ) AS DOCUMENTOS_PENDIENTES

    FROM bbf_aspirantes A
    LEFT JOIN bbf_tipos_documento TD
        ON TD.ID_TIPO_DOCUMENTO = A.ID_TIPO_DOCUMENTO
    LEFT JOIN bbf_areas AR
        ON AR.ID_AREA = A.ID_AREA_ASPIRA
    LEFT JOIN bbf_cargos C
        ON C.ID_CARGO = A.ID_CARGO_ASPIRA
    LEFT JOIN bbf_aspirante_documentos D
        ON D.ID_ASPIRANTE = A.ID_ASPIRANTE
       AND IFNULL(D.ELIMINADO, 0) = 0
    WHERE IFNULL(A.ELIMINADO, 0) = 0
      AND (P_ESTADO_ASPIRANTE IS NULL OR P_ESTADO_ASPIRANTE = '' OR A.ESTADO_ASPIRANTE = P_ESTADO_ASPIRANTE)
      AND (P_ID_AREA IS NULL OR P_ID_AREA = 0 OR A.ID_AREA_ASPIRA = P_ID_AREA)
      AND (P_ID_CARGO IS NULL OR P_ID_CARGO = 0 OR A.ID_CARGO_ASPIRA = P_ID_CARGO)
      AND (
            P_TEXTO_BUSQUEDA IS NULL
            OR P_TEXTO_BUSQUEDA = ''
            OR A.NUMERO_DOCUMENTO LIKE CONCAT('%', P_TEXTO_BUSQUEDA, '%')
            OR A.NOMBRES LIKE CONCAT('%', P_TEXTO_BUSQUEDA, '%')
            OR A.APELLIDOS LIKE CONCAT('%', P_TEXTO_BUSQUEDA, '%')
            OR A.CORREO LIKE CONCAT('%', P_TEXTO_BUSQUEDA, '%')
      )
    GROUP BY
        A.ID_ASPIRANTE,
        A.ID_TIPO_DOCUMENTO,
        TD.NOMBRE,
        A.NUMERO_DOCUMENTO,
        A.NOMBRES,
        A.APELLIDOS,
        A.CORREO,
        A.TELEFONO,
        A.DIRECCION,
        A.FECHA_NACIMIENTO,
        A.LUGAR_NACIMIENTO,
        A.NACIONALIDAD,
        A.ID_AREA_ASPIRA,
        AR.NOMBRE,
        A.ID_CARGO_ASPIRA,
        C.NOMBRE,
        A.ESTADO_ASPIRANTE,
        A.OBSERVACIONES,
        A.ID_EMPLEADO_GENERADO,
        A.CREATED_AT,
        A.UPDATED_AT
    ORDER BY A.CREATED_AT DESC, A.ID_ASPIRANTE DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_ASPIRANTES_OBTENER` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_ASPIRANTES_OBTENER`(
    IN P_ID_ASPIRANTE INT
)
BEGIN

    SELECT
        ASP.ID_ASPIRANTE,

        ASP.ID_TIPO_DOCUMENTO,
        TD.NOMBRE AS TIPO_DOCUMENTO,

        ASP.NUMERO_DOCUMENTO,
        ASP.NOMBRES,
        ASP.APELLIDOS,

        CONCAT(
            ASP.NOMBRES,
            ' ',
            ASP.APELLIDOS
        ) AS NOMBRE_COMPLETO,

        ASP.CORREO,
        ASP.TELEFONO,
        ASP.DIRECCION,
        ASP.FECHA_NACIMIENTO,

        ASP.ID_DEPARTAMENTO_NACIMIENTO,

        DN.CODIGO_DANE
            AS CODIGO_DEPARTAMENTO_NACIMIENTO,

        COALESCE(
            DN.NOMBRE,
            ASP.DEPARTAMENTO_NACIMIENTO
        ) AS DEPARTAMENTO_NACIMIENTO,

        ASP.ID_MUNICIPIO_NACIMIENTO,

        MN.CODIGO_DANE
            AS CODIGO_MUNICIPIO_NACIMIENTO,

        COALESCE(
            MN.NOMBRE,
            ASP.LUGAR_NACIMIENTO
        ) AS LUGAR_NACIMIENTO,

        ASP.NACIONALIDAD,

        ASP.ID_DEPARTAMENTO_RESIDENCIA,

        DR.CODIGO_DANE
            AS CODIGO_DEPARTAMENTO_RESIDENCIA,

        COALESCE(
            DR.NOMBRE,
            ASP.DEPARTAMENTO_RESIDENCIA
        ) AS DEPARTAMENTO_RESIDENCIA,

        ASP.ID_MUNICIPIO_RESIDENCIA,

        MR.CODIGO_DANE
            AS CODIGO_MUNICIPIO_RESIDENCIA,

        COALESCE(
            MR.NOMBRE,
            ASP.CIUDAD_RESIDENCIA
        ) AS CIUDAD_RESIDENCIA,

        ASP.ESTADO_CIVIL,
        ASP.NIVEL_EDUCATIVO,
        ASP.PERSONAS_A_CARGO,
        ASP.NUMERO_HIJOS,

        ASP.ID_AREA_ASPIRA,
        AR.NOMBRE AS AREA_ASPIRA,

        ASP.ID_CARGO_ASPIRA,
        C.NOMBRE AS CARGO_ASPIRA,

        ASP.ESTADO_ASPIRANTE,
        ASP.OBSERVACIONES,
        ASP.ID_EMPLEADO_GENERADO,

        ASP.CREATED_AT,
        ASP.UPDATED_AT

    FROM bbf_aspirantes ASP

    LEFT JOIN bbf_tipos_documento TD
        ON TD.ID_TIPO_DOCUMENTO =
           ASP.ID_TIPO_DOCUMENTO

    LEFT JOIN bbf_areas AR
        ON AR.ID_AREA =
           ASP.ID_AREA_ASPIRA

    LEFT JOIN bbf_cargos C
        ON C.ID_CARGO =
           ASP.ID_CARGO_ASPIRA

    LEFT JOIN bbf_departamentos DN
        ON DN.ID_DEPARTAMENTO =
           ASP.ID_DEPARTAMENTO_NACIMIENTO

    LEFT JOIN bbf_municipios MN
        ON MN.ID_MUNICIPIO =
           ASP.ID_MUNICIPIO_NACIMIENTO

    LEFT JOIN bbf_departamentos DR
        ON DR.ID_DEPARTAMENTO =
           ASP.ID_DEPARTAMENTO_RESIDENCIA

    LEFT JOIN bbf_municipios MR
        ON MR.ID_MUNICIPIO =
           ASP.ID_MUNICIPIO_RESIDENCIA

    WHERE ASP.ID_ASPIRANTE = P_ID_ASPIRANTE
      AND IFNULL(ASP.ELIMINADO, 0) = 0

    LIMIT 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CAPACITACIONES_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CAPACITACIONES_LISTAR`(IN P_TIPO VARCHAR(30), IN P_INCLUIR_INACTIVAS TINYINT)
BEGIN
    SELECT C.*,COUNT(CASE WHEN D.ACTIVO=1 THEN 1 END) AS TOTAL_LABORES
    FROM bbf_capacitaciones C
    LEFT JOIN bbf_capacitacion_labor_detalle D ON D.ID_CAPACITACION=C.ID_CAPACITACION
    WHERE (NULLIF(TRIM(P_TIPO),'') IS NULL OR C.TIPO=UPPER(TRIM(P_TIPO)))
      AND (IFNULL(P_INCLUIR_INACTIVAS,0)=1 OR C.ACTIVO=1)
    GROUP BY C.ID_CAPACITACION
    ORDER BY C.ACTIVO DESC,C.NOMBRE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CAPACITACION_ALERTAS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CAPACITACION_ALERTAS_LISTAR`(IN P_ID_EMPLEADO INT)
BEGIN
    SELECT 'EVALUACION_PENDIENTE' AS TIPO_ALERTA,NULL AS ID_CAPACITACION_RESULTADO,
    P.ID_CAPACITACION_PARTICIPANTE,E.ID_EMPLEADO,E.NUMERO_DOCUMENTO,
    CONCAT_WS(' ',E.NOMBRES,E.APELLIDOS) AS EMPLEADO,C.NOMBRE AS CAPACITACION,
    S.FECHA_FIN AS FECHA_REFERENCIA,NULL AS RESULTADO,0 AS REQUIERE_COMPROMISO,
    'La evaluacion de la capacitacion se encuentra pendiente.' AS MENSAJE,
    NULL AS ID_CAPACITACION_COMPROMISO
    FROM bbf_capacitacion_participantes P
    INNER JOIN bbf_empleados E ON E.ID_EMPLEADO=P.ID_EMPLEADO
    INNER JOIN bbf_capacitacion_sesiones S ON S.ID_CAPACITACION_SESION=P.ID_CAPACITACION_SESION
    INNER JOIN bbf_capacitaciones C ON C.ID_CAPACITACION=S.ID_CAPACITACION
    WHERE P.ESTADO_EVALUACION IN('PENDIENTE','EN_PROCESO') AND S.ESTADO<>'ANULADA'
      AND (P_ID_EMPLEADO IS NULL OR P_ID_EMPLEADO=0 OR E.ID_EMPLEADO=P_ID_EMPLEADO)

    UNION ALL

    SELECT 'RESULTADO_NO_APROBADO',R.ID_CAPACITACION_RESULTADO,
    P.ID_CAPACITACION_PARTICIPANTE,E.ID_EMPLEADO,E.NUMERO_DOCUMENTO,
    CONCAT_WS(' ',E.NOMBRES,E.APELLIDOS),C.NOMBRE,R.FECHA_RESULTADO,R.RESULTADO,
    R.REQUIERE_COMPROMISO,
    CONCAT('Resultado ',R.RESULTADO,'. Puntaje: ',COALESCE(R.PUNTAJE_FINAL,'sin definir'),'.'),
    CO.ID_CAPACITACION_COMPROMISO
    FROM bbf_capacitacion_resultados R
    INNER JOIN bbf_capacitacion_participantes P ON P.ID_CAPACITACION_PARTICIPANTE=R.ID_CAPACITACION_PARTICIPANTE
    INNER JOIN bbf_empleados E ON E.ID_EMPLEADO=P.ID_EMPLEADO
    INNER JOIN bbf_capacitacion_sesiones S ON S.ID_CAPACITACION_SESION=P.ID_CAPACITACION_SESION
    INNER JOIN bbf_capacitaciones C ON C.ID_CAPACITACION=S.ID_CAPACITACION
    LEFT JOIN bbf_capacitacion_compromisos CO ON CO.ID_CAPACITACION_RESULTADO=R.ID_CAPACITACION_RESULTADO
    WHERE R.RESULTADO IN('NO_APROBADO','REQUIERE_REINDUCCION')
      AND (P_ID_EMPLEADO IS NULL OR P_ID_EMPLEADO=0 OR E.ID_EMPLEADO=P_ID_EMPLEADO)
    ORDER BY FECHA_REFERENCIA DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CAPACITACION_ASISTENCIA_REGISTRAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CAPACITACION_ASISTENCIA_REGISTRAR`(
    IN P_ID_PARTICIPANTE INT, IN P_ESTADO VARCHAR(20), IN P_OBSERVACIONES TEXT
)
BEGIN
    DECLARE V_ESTADO VARCHAR(20);
    SET V_ESTADO=UPPER(TRIM(P_ESTADO));
    IF V_ESTADO NOT IN('PENDIENTE','ASISTIO','NO_ASISTIO','JUSTIFICADO','INCAPACITADO') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Estado de asistencia no valido.';
    END IF;
    UPDATE bbf_capacitacion_participantes SET ESTADO_ASISTENCIA=V_ESTADO,
    ESTADO_EVALUACION=CASE
        WHEN V_ESTADO IN('NO_ASISTIO','JUSTIFICADO','INCAPACITADO') THEN 'NO_APLICA'
        WHEN V_ESTADO='ASISTIO' AND ESTADO_EVALUACION='NO_APLICA' THEN 'PENDIENTE'
        ELSE ESTADO_EVALUACION
    END,
    OBSERVACIONES=COALESCE(NULLIF(TRIM(P_OBSERVACIONES),''),OBSERVACIONES)
    WHERE ID_CAPACITACION_PARTICIPANTE=P_ID_PARTICIPANTE;
    SELECT * FROM bbf_capacitacion_participantes WHERE ID_CAPACITACION_PARTICIPANTE=P_ID_PARTICIPANTE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CAPACITACION_COMPROMISOS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CAPACITACION_COMPROMISOS_LISTAR`(IN P_ID_EMPLEADO INT, IN P_ESTADO VARCHAR(30))
BEGIN
    SELECT CO.*,R.RESULTADO,R.PUNTAJE_FINAL,R.PUNTAJE_MINIMO_APLICADO,E.ID_EMPLEADO,E.NUMERO_DOCUMENTO,
    CONCAT_WS(' ',E.NOMBRES,E.APELLIDOS) AS EMPLEADO,C.NOMBRE AS CAPACITACION,S.FECHA_INICIO,S.FECHA_FIN
    FROM bbf_capacitacion_compromisos CO INNER JOIN bbf_capacitacion_resultados R ON R.ID_CAPACITACION_RESULTADO=CO.ID_CAPACITACION_RESULTADO
    INNER JOIN bbf_capacitacion_participantes P ON P.ID_CAPACITACION_PARTICIPANTE=R.ID_CAPACITACION_PARTICIPANTE
    INNER JOIN bbf_empleados E ON E.ID_EMPLEADO=P.ID_EMPLEADO
    INNER JOIN bbf_capacitacion_sesiones S ON S.ID_CAPACITACION_SESION=P.ID_CAPACITACION_SESION
    INNER JOIN bbf_capacitaciones C ON C.ID_CAPACITACION=S.ID_CAPACITACION
    WHERE (P_ID_EMPLEADO IS NULL OR P_ID_EMPLEADO=0 OR E.ID_EMPLEADO=P_ID_EMPLEADO)
      AND (NULLIF(TRIM(P_ESTADO),'') IS NULL OR CO.ESTADO=UPPER(TRIM(P_ESTADO)))
    ORDER BY CO.FECHA_COMPROMISO DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CAPACITACION_COMPROMISO_ACTUALIZAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CAPACITACION_COMPROMISO_ACTUALIZAR`(
    IN P_ID_COMPROMISO INT, IN P_ESTADO VARCHAR(30), IN P_DOCUMENTO_URL VARCHAR(500),
    IN P_DOCUMENTO_RUTA VARCHAR(500), IN P_FIRMA_URL VARCHAR(500), IN P_OBSERVACIONES TEXT, IN P_ID_USUARIO INT
)
BEGIN
    DECLARE V_ESTADO VARCHAR(30); SET V_ESTADO=UPPER(TRIM(P_ESTADO));
    IF V_ESTADO NOT IN('BORRADOR','PENDIENTE_FIRMA','FIRMADO','CUMPLIDO','INCUMPLIDO','ANULADO') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Estado de compromiso no valido.';
    END IF;
    IF NOT EXISTS(SELECT 1 FROM bbf_capacitacion_compromisos WHERE ID_CAPACITACION_COMPROMISO=P_ID_COMPROMISO) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El compromiso no existe.';
    END IF;
    UPDATE bbf_capacitacion_compromisos SET ESTADO=V_ESTADO,
    DOCUMENTO_URL=COALESCE(NULLIF(TRIM(P_DOCUMENTO_URL),''),DOCUMENTO_URL),
    DOCUMENTO_RUTA=COALESCE(NULLIF(TRIM(P_DOCUMENTO_RUTA),''),DOCUMENTO_RUTA),
    FIRMA_URL=COALESCE(NULLIF(TRIM(P_FIRMA_URL),''),FIRMA_URL),
    FECHA_FIRMA=CASE WHEN V_ESTADO IN('FIRMADO','CUMPLIDO','INCUMPLIDO') AND FECHA_FIRMA IS NULL THEN CURRENT_TIMESTAMP ELSE FECHA_FIRMA END,
    ID_CERRADO_POR=CASE WHEN V_ESTADO IN('CUMPLIDO','INCUMPLIDO','ANULADO') THEN P_ID_USUARIO ELSE ID_CERRADO_POR END,
    OBSERVACIONES=COALESCE(NULLIF(TRIM(P_OBSERVACIONES),''),OBSERVACIONES)
    WHERE ID_CAPACITACION_COMPROMISO=P_ID_COMPROMISO;
    SELECT * FROM bbf_capacitacion_compromisos WHERE ID_CAPACITACION_COMPROMISO=P_ID_COMPROMISO;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CAPACITACION_COMPROMISO_CREAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CAPACITACION_COMPROMISO_CREAR`(
    IN P_ID_RESULTADO INT, IN P_FECHA DATE, IN P_FECHA_LIMITE DATE, IN P_MOTIVO TEXT,
    IN P_COMPROMISOS TEXT, IN P_OBSERVACIONES TEXT, IN P_ID_USUARIO INT
)
BEGIN
    IF NOT EXISTS(SELECT 1 FROM bbf_capacitacion_resultados WHERE ID_CAPACITACION_RESULTADO=P_ID_RESULTADO AND RESULTADO IN('NO_APROBADO','REQUIERE_REINDUCCION')) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Solo se puede generar compromiso para un resultado no aprobado.';
    END IF;
    INSERT INTO bbf_capacitacion_compromisos(ID_CAPACITACION_RESULTADO,FECHA_COMPROMISO,FECHA_LIMITE,MOTIVO,
    COMPROMISOS_EMPLEADO,ESTADO,OBSERVACIONES,ID_CREADO_POR)
    VALUES(P_ID_RESULTADO,IFNULL(P_FECHA,CURRENT_DATE),P_FECHA_LIMITE,TRIM(P_MOTIVO),NULLIF(TRIM(P_COMPROMISOS),''),'BORRADOR',
    NULLIF(TRIM(P_OBSERVACIONES),''),P_ID_USUARIO);
    UPDATE bbf_capacitacion_resultados SET REQUIERE_COMPROMISO=1 WHERE ID_CAPACITACION_RESULTADO=P_ID_RESULTADO;
    SELECT * FROM bbf_capacitacion_compromisos WHERE ID_CAPACITACION_COMPROMISO=LAST_INSERT_ID();
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CAPACITACION_COMPROMISO_OBTENER` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CAPACITACION_COMPROMISO_OBTENER`(IN P_ID_COMPROMISO INT)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM bbf_capacitacion_compromisos
        WHERE ID_CAPACITACION_COMPROMISO = P_ID_COMPROMISO
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El compromiso de capacitacion no existe.';
    END IF;

    SELECT
        CO.ID_CAPACITACION_COMPROMISO,
        CO.ID_CAPACITACION_RESULTADO,
        CO.FECHA_COMPROMISO,
        CO.FECHA_LIMITE,
        CO.MOTIVO,
        CO.COMPROMISOS_EMPLEADO,
        CO.ESTADO,
        CO.DOCUMENTO_URL,
        CO.DOCUMENTO_RUTA,
        CO.FIRMA_URL,
        CO.FECHA_FIRMA,
        CO.OBSERVACIONES,
        CO.CREATED_AT,
        CO.UPDATED_AT,
        R.RESULTADO,
        R.TOTAL_ACUMULADO,
        R.PUNTAJE_FINAL,
        R.PUNTAJE_MINIMO_APLICADO,
        R.FECHA_RESULTADO,
        R.REGLA_APLICADA,
        E.ID_EMPLEADO,
        E.NUMERO_DOCUMENTO,
        CONCAT_WS(' ', E.NOMBRES, E.APELLIDOS) AS EMPLEADO,
        CARGO.NOMBRE AS CARGO,
        AREA.NOMBRE AS AREA,
        CAP.ID_CAPACITACION,
        CAP.CODIGO AS CODIGO_CAPACITACION,
        CAP.NOMBRE AS CAPACITACION,
        CAP.TIPO AS TIPO_CAPACITACION,
        S.ID_CAPACITACION_SESION,
        S.FECHA_INICIO,
        S.FECHA_FIN,
        S.SEMANA_ISO AS NUMERO_SEMANA,
        S.LUGAR,
        U.NOMBRE_USUARIO AS CREADO_POR
    FROM bbf_capacitacion_compromisos CO
    INNER JOIN bbf_capacitacion_resultados R
        ON R.ID_CAPACITACION_RESULTADO = CO.ID_CAPACITACION_RESULTADO
    INNER JOIN bbf_capacitacion_participantes P
        ON P.ID_CAPACITACION_PARTICIPANTE = R.ID_CAPACITACION_PARTICIPANTE
    INNER JOIN bbf_empleados E
        ON E.ID_EMPLEADO = P.ID_EMPLEADO
    LEFT JOIN bbf_cargos CARGO
        ON CARGO.ID_CARGO = E.ID_CARGO
    LEFT JOIN bbf_areas AREA
        ON AREA.ID_AREA = E.ID_AREA
    INNER JOIN bbf_capacitacion_sesiones S
        ON S.ID_CAPACITACION_SESION = P.ID_CAPACITACION_SESION
    INNER JOIN bbf_capacitaciones CAP
        ON CAP.ID_CAPACITACION = S.ID_CAPACITACION
    LEFT JOIN bbf_usuarios U
        ON U.ID_USUARIO = CO.ID_CREADO_POR
    WHERE CO.ID_CAPACITACION_COMPROMISO = P_ID_COMPROMISO;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CAPACITACION_CONFIRMAR_EMPLEADO` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CAPACITACION_CONFIRMAR_EMPLEADO`(
    IN P_ID_USUARIO INT, IN P_ID_PARTICIPANTE INT, IN P_OBSERVACION VARCHAR(500)
)
BEGIN
    DECLARE V_ID_EMPLEADO INT; DECLARE V_ID_EMPLEADO_PART INT; DECLARE V_ASISTENCIA VARCHAR(20);
    SELECT ID_EMPLEADO INTO V_ID_EMPLEADO FROM bbf_usuarios WHERE ID_USUARIO=P_ID_USUARIO AND ESTADO='ACTIVO' LIMIT 1;
    SELECT ID_EMPLEADO,ESTADO_ASISTENCIA INTO V_ID_EMPLEADO_PART,V_ASISTENCIA
    FROM bbf_capacitacion_participantes WHERE ID_CAPACITACION_PARTICIPANTE=P_ID_PARTICIPANTE LIMIT 1;
    IF V_ID_EMPLEADO IS NULL OR V_ID_EMPLEADO<>V_ID_EMPLEADO_PART THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='No puede confirmar una capacitacion asociada a otro empleado.';
    END IF;
    IF V_ASISTENCIA<>'ASISTIO' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Solo puede confirmar una capacitacion con asistencia registrada.';
    END IF;
    UPDATE bbf_capacitacion_participantes SET CONFIRMO_RECIBIDO=1,FECHA_CONFIRMACION=CURRENT_TIMESTAMP,
    ID_CONFIRMADO_POR=P_ID_USUARIO,MODALIDAD_CONFIRMACION='EMPLEADO',OBSERVACION_CONFIRMACION=NULLIF(TRIM(P_OBSERVACION),'')
    WHERE ID_CAPACITACION_PARTICIPANTE=P_ID_PARTICIPANTE AND CONFIRMO_RECIBIDO=0;
    SELECT * FROM bbf_capacitacion_participantes WHERE ID_CAPACITACION_PARTICIPANTE=P_ID_PARTICIPANTE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CAPACITACION_CONFIRMAR_RRHH` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CAPACITACION_CONFIRMAR_RRHH`(
    IN P_ID_USUARIO_RRHH INT, IN P_ID_PARTICIPANTE INT, IN P_OBSERVACION VARCHAR(500)
)
BEGIN
    IF NOT EXISTS(SELECT 1 FROM bbf_usuarios WHERE ID_USUARIO=P_ID_USUARIO_RRHH AND ESTADO='ACTIVO') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El usuario de RRHH no existe o esta inactivo.';
    END IF;
    IF NOT EXISTS(SELECT 1 FROM bbf_capacitacion_participantes WHERE ID_CAPACITACION_PARTICIPANTE=P_ID_PARTICIPANTE AND ESTADO_ASISTENCIA='ASISTIO') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Solo se puede confirmar una capacitacion con asistencia registrada.';
    END IF;
    UPDATE bbf_capacitacion_participantes SET CONFIRMO_RECIBIDO=1,FECHA_CONFIRMACION=CURRENT_TIMESTAMP,
    ID_CONFIRMADO_POR=P_ID_USUARIO_RRHH,MODALIDAD_CONFIRMACION='PRESENCIAL_RRHH',
    OBSERVACION_CONFIRMACION=COALESCE(NULLIF(TRIM(P_OBSERVACION),''),'Confirmacion presencial registrada por Recursos Humanos.')
    WHERE ID_CAPACITACION_PARTICIPANTE=P_ID_PARTICIPANTE AND CONFIRMO_RECIBIDO=0;
    SELECT * FROM bbf_capacitacion_participantes WHERE ID_CAPACITACION_PARTICIPANTE=P_ID_PARTICIPANTE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CAPACITACION_EVALUACION_GUARDAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CAPACITACION_EVALUACION_GUARDAR`(
    IN P_ID_PARTICIPANTE INT, IN P_ID_LABOR INT, IN P_FECHA DATE,
    IN P_VALOR DECIMAL(12,2), IN P_VALOR_MAXIMO DECIMAL(12,2), IN P_REQUIERE_ATENCION TINYINT,
    IN P_OBSERVACIONES VARCHAR(500), IN P_ID_EVALUADOR INT, IN P_ORIGEN VARCHAR(10), IN P_ID_IMPORTACION BIGINT
)
BEGIN
    DECLARE V_INICIO DATE; DECLARE V_FIN DATE; DECLARE V_ID_CAPACITACION INT;
    SELECT S.FECHA_INICIO,S.FECHA_FIN,S.ID_CAPACITACION INTO V_INICIO,V_FIN,V_ID_CAPACITACION
    FROM bbf_capacitacion_participantes P INNER JOIN bbf_capacitacion_sesiones S ON S.ID_CAPACITACION_SESION=P.ID_CAPACITACION_SESION
    WHERE P.ID_CAPACITACION_PARTICIPANTE=P_ID_PARTICIPANTE LIMIT 1;
    IF V_INICIO IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El participante no existe.'; END IF;
    IF P_FECHA<V_INICIO OR P_FECHA>V_FIN THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La fecha no pertenece al periodo de la sesion.'; END IF;
    IF P_VALOR IS NULL OR P_VALOR<0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El valor obtenido debe ser mayor o igual a cero.'; END IF;
    IF NOT EXISTS(SELECT 1 FROM bbf_capacitacion_labor_detalle WHERE ID_CAPACITACION=V_ID_CAPACITACION AND ID_CAPACITACION_LABOR=P_ID_LABOR AND ACTIVO=1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La labor no pertenece a la capacitacion.';
    END IF;
    INSERT INTO bbf_capacitacion_evaluaciones(ID_CAPACITACION_PARTICIPANTE,ID_CAPACITACION_LABOR,FECHA_EVALUACION,
    VALOR_OBTENIDO,VALOR_MAXIMO,REQUIERE_ATENCION,OBSERVACIONES,ID_EVALUADO_POR,ORIGEN,ID_CAPACITACION_IMPORTACION)
    VALUES(P_ID_PARTICIPANTE,P_ID_LABOR,P_FECHA,P_VALOR,P_VALOR_MAXIMO,IFNULL(P_REQUIERE_ATENCION,0),
    NULLIF(TRIM(P_OBSERVACIONES),''),P_ID_EVALUADOR,IF(UPPER(P_ORIGEN)='EXCEL','EXCEL','MANUAL'),P_ID_IMPORTACION)
    ON DUPLICATE KEY UPDATE VALOR_OBTENIDO=VALUES(VALOR_OBTENIDO),VALOR_MAXIMO=VALUES(VALOR_MAXIMO),
    REQUIERE_ATENCION=VALUES(REQUIERE_ATENCION),OBSERVACIONES=VALUES(OBSERVACIONES),ID_EVALUADO_POR=VALUES(ID_EVALUADO_POR),
    ORIGEN=VALUES(ORIGEN),ID_CAPACITACION_IMPORTACION=VALUES(ID_CAPACITACION_IMPORTACION);
    UPDATE bbf_capacitacion_participantes SET ESTADO_EVALUACION='EN_PROCESO' WHERE ID_CAPACITACION_PARTICIPANTE=P_ID_PARTICIPANTE AND ESTADO_EVALUACION='PENDIENTE';
    SELECT * FROM bbf_capacitacion_evaluaciones WHERE ID_CAPACITACION_PARTICIPANTE=P_ID_PARTICIPANTE AND ID_CAPACITACION_LABOR=P_ID_LABOR AND FECHA_EVALUACION=P_FECHA;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CAPACITACION_GUARDAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CAPACITACION_GUARDAR`(
    IN P_ID_CAPACITACION INT, IN P_CODIGO VARCHAR(50), IN P_NOMBRE VARCHAR(200),
    IN P_DESCRIPCION TEXT, IN P_TIPO VARCHAR(30), IN P_REQUIERE_EVALUACION TINYINT,
    IN P_REQUIERE_CONFIRMACION TINYINT, IN P_PUNTAJE_MINIMO DECIMAL(10,2),
    IN P_PUNTAJE_MAXIMO DECIMAL(10,2), IN P_REGLA_CALCULO VARCHAR(500),
    IN P_GENERAR_COMPROMISO TINYINT, IN P_DIAS_PARA_EVALUAR INT,
    IN P_ACTIVO TINYINT, IN P_ID_USUARIO INT
)
BEGIN
    DECLARE V_TIPO VARCHAR(30);
    SET V_TIPO=UPPER(TRIM(P_TIPO));
    IF V_TIPO NOT IN('CAPACITACION','INDUCCION','REINDUCCION','EVALUACION_REINDUCCION') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Tipo de capacitacion no valido.';
    END IF;
    IF P_PUNTAJE_MINIMO IS NOT NULL AND P_PUNTAJE_MAXIMO IS NOT NULL AND P_PUNTAJE_MINIMO>P_PUNTAJE_MAXIMO THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El puntaje minimo no puede superar el maximo.';
    END IF;
    IF P_ID_CAPACITACION IS NULL OR P_ID_CAPACITACION=0 THEN
        INSERT INTO bbf_capacitaciones(CODIGO,NOMBRE,DESCRIPCION,TIPO,REQUIERE_EVALUACION,REQUIERE_CONFIRMACION,
        PUNTAJE_MINIMO,PUNTAJE_MAXIMO,REGLA_CALCULO,GENERAR_COMPROMISO_NO_APROBADO,DIAS_PARA_EVALUAR,ACTIVO,ID_CREADO_POR)
        VALUES(UPPER(TRIM(P_CODIGO)),TRIM(P_NOMBRE),NULLIF(TRIM(P_DESCRIPCION),''),V_TIPO,
        IFNULL(P_REQUIERE_EVALUACION,1),IFNULL(P_REQUIERE_CONFIRMACION,1),P_PUNTAJE_MINIMO,P_PUNTAJE_MAXIMO,
        NULLIF(TRIM(P_REGLA_CALCULO),''),IFNULL(P_GENERAR_COMPROMISO,0),P_DIAS_PARA_EVALUAR,IFNULL(P_ACTIVO,1),P_ID_USUARIO);
        SET P_ID_CAPACITACION=LAST_INSERT_ID();
    ELSE
        UPDATE bbf_capacitaciones SET CODIGO=UPPER(TRIM(P_CODIGO)),NOMBRE=TRIM(P_NOMBRE),
        DESCRIPCION=NULLIF(TRIM(P_DESCRIPCION),''),TIPO=V_TIPO,REQUIERE_EVALUACION=IFNULL(P_REQUIERE_EVALUACION,1),
        REQUIERE_CONFIRMACION=IFNULL(P_REQUIERE_CONFIRMACION,1),PUNTAJE_MINIMO=P_PUNTAJE_MINIMO,
        PUNTAJE_MAXIMO=P_PUNTAJE_MAXIMO,REGLA_CALCULO=NULLIF(TRIM(P_REGLA_CALCULO),''),
        GENERAR_COMPROMISO_NO_APROBADO=IFNULL(P_GENERAR_COMPROMISO,0),DIAS_PARA_EVALUAR=P_DIAS_PARA_EVALUAR,
        ACTIVO=IFNULL(P_ACTIVO,1) WHERE ID_CAPACITACION=P_ID_CAPACITACION;
    END IF;
    SELECT * FROM bbf_capacitaciones WHERE ID_CAPACITACION=P_ID_CAPACITACION;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CAPACITACION_IMPORTACION_CREAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CAPACITACION_IMPORTACION_CREAR`(
    IN P_ID_SESION INT, IN P_NOMBRE_ARCHIVO VARCHAR(255), IN P_NOMBRE_ORIGINAL VARCHAR(255),
    IN P_RUTA VARCHAR(500), IN P_MIME VARCHAR(100), IN P_PESO BIGINT, IN P_ID_USUARIO INT
)
BEGIN
    INSERT INTO bbf_capacitacion_importaciones(ID_CAPACITACION_SESION,NOMBRE_ARCHIVO,NOMBRE_ORIGINAL,ARCHIVO_RUTA,MIME_TYPE,PESO_BYTES,ID_CARGADO_POR)
    VALUES(P_ID_SESION,TRIM(P_NOMBRE_ARCHIVO),TRIM(P_NOMBRE_ORIGINAL),TRIM(P_RUTA),NULLIF(TRIM(P_MIME),''),P_PESO,P_ID_USUARIO);
    SELECT * FROM bbf_capacitacion_importaciones WHERE ID_CAPACITACION_IMPORTACION=LAST_INSERT_ID();
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CAPACITACION_IMPORTACION_ERROR_AGREGAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CAPACITACION_IMPORTACION_ERROR_AGREGAR`(
    IN P_ID_IMPORTACION BIGINT, IN P_HOJA VARCHAR(150), IN P_CELDA VARCHAR(30), IN P_FILA INT,
    IN P_EMPLEADO VARCHAR(250), IN P_LABOR VARCHAR(250), IN P_VALOR VARCHAR(500), IN P_CODIGO VARCHAR(80), IN P_MENSAJE VARCHAR(500)
)
BEGIN
    INSERT INTO bbf_capacitacion_importacion_errores(ID_CAPACITACION_IMPORTACION,HOJA,CELDA,FILA,EMPLEADO_ORIGINAL,LABOR_ORIGINAL,VALOR_ORIGINAL,CODIGO_ERROR,MENSAJE)
    VALUES(P_ID_IMPORTACION,NULLIF(TRIM(P_HOJA),''),NULLIF(TRIM(P_CELDA),''),P_FILA,NULLIF(TRIM(P_EMPLEADO),''),NULLIF(TRIM(P_LABOR),''),
    NULLIF(TRIM(P_VALOR),''),UPPER(TRIM(P_CODIGO)),TRIM(P_MENSAJE));
    UPDATE bbf_capacitacion_importaciones SET TOTAL_ERRORES=TOTAL_ERRORES+1,ESTADO='CON_ERRORES' WHERE ID_CAPACITACION_IMPORTACION=P_ID_IMPORTACION;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CAPACITACION_IMPORTACION_FINALIZAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CAPACITACION_IMPORTACION_FINALIZAR`(
    IN P_ID_IMPORTACION BIGINT, IN P_ESTADO VARCHAR(20), IN P_TOTAL INT, IN P_VALIDOS INT, IN P_RESUMEN TEXT
)
BEGIN
    DECLARE V_ESTADO VARCHAR(20); SET V_ESTADO=UPPER(TRIM(P_ESTADO));
    IF V_ESTADO NOT IN('CON_ERRORES','VALIDADA','IMPORTADA','ANULADA') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Estado de importacion no valido.'; END IF;
    UPDATE bbf_capacitacion_importaciones SET ESTADO=V_ESTADO,TOTAL_REGISTROS=IFNULL(P_TOTAL,0),TOTAL_VALIDOS=IFNULL(P_VALIDOS,0),
    TOTAL_ERRORES=(SELECT COUNT(*) FROM bbf_capacitacion_importacion_errores WHERE ID_CAPACITACION_IMPORTACION=P_ID_IMPORTACION),
    RESUMEN=P_RESUMEN,FECHA_IMPORTACION=CASE WHEN V_ESTADO='IMPORTADA' THEN CURRENT_TIMESTAMP ELSE FECHA_IMPORTACION END
    WHERE ID_CAPACITACION_IMPORTACION=P_ID_IMPORTACION;
    SELECT * FROM bbf_capacitacion_importaciones WHERE ID_CAPACITACION_IMPORTACION=P_ID_IMPORTACION;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CAPACITACION_LABORES_ASOCIADAS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CAPACITACION_LABORES_ASOCIADAS_LISTAR`(IN P_ID_CAPACITACION INT, IN P_INCLUIR_INACTIVAS TINYINT)
BEGIN
    SELECT D.ID_CAPACITACION_LABOR_DETALLE,D.ID_CAPACITACION,D.ID_CAPACITACION_LABOR,
    L.CODIGO,L.NOMBRE,L.DESCRIPCION,D.PUNTAJE_MINIMO_LABOR,D.PUNTAJE_MAXIMO_LABOR,
    D.ORDEN,D.ACTIVO
    FROM bbf_capacitacion_labor_detalle D
    INNER JOIN bbf_capacitacion_labores L ON L.ID_CAPACITACION_LABOR=D.ID_CAPACITACION_LABOR
    WHERE D.ID_CAPACITACION=P_ID_CAPACITACION
      AND (IFNULL(P_INCLUIR_INACTIVAS,0)=1 OR (D.ACTIVO=1 AND L.ACTIVO=1))
    ORDER BY D.ORDEN,L.ORDEN,L.NOMBRE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CAPACITACION_LABORES_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CAPACITACION_LABORES_LISTAR`(IN P_INCLUIR_INACTIVAS TINYINT)
BEGIN
    SELECT ID_CAPACITACION_LABOR,CODIGO,NOMBRE,DESCRIPCION,ORDEN,ACTIVO,CREATED_AT,UPDATED_AT
    FROM bbf_capacitacion_labores
    WHERE IFNULL(P_INCLUIR_INACTIVAS,0)=1 OR ACTIVO=1
    ORDER BY ORDEN,NOMBRE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CAPACITACION_LABOR_ASOCIAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CAPACITACION_LABOR_ASOCIAR`(
    IN P_ID_CAPACITACION INT, IN P_ID_CAPACITACION_LABOR INT,
    IN P_PUNTAJE_MINIMO DECIMAL(10,2), IN P_PUNTAJE_MAXIMO DECIMAL(10,2), IN P_ORDEN INT
)
BEGIN
    IF NOT EXISTS(SELECT 1 FROM bbf_capacitaciones WHERE ID_CAPACITACION=P_ID_CAPACITACION AND ACTIVO=1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La capacitacion no existe o esta inactiva.';
    END IF;
    IF NOT EXISTS(SELECT 1 FROM bbf_capacitacion_labores WHERE ID_CAPACITACION_LABOR=P_ID_CAPACITACION_LABOR AND ACTIVO=1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La labor no existe o esta inactiva.';
    END IF;
    INSERT INTO bbf_capacitacion_labor_detalle(ID_CAPACITACION,ID_CAPACITACION_LABOR,PUNTAJE_MINIMO_LABOR,PUNTAJE_MAXIMO_LABOR,ORDEN,ACTIVO)
    VALUES(P_ID_CAPACITACION,P_ID_CAPACITACION_LABOR,P_PUNTAJE_MINIMO,P_PUNTAJE_MAXIMO,IFNULL(P_ORDEN,0),1)
    ON DUPLICATE KEY UPDATE PUNTAJE_MINIMO_LABOR=VALUES(PUNTAJE_MINIMO_LABOR),PUNTAJE_MAXIMO_LABOR=VALUES(PUNTAJE_MAXIMO_LABOR),ORDEN=VALUES(ORDEN),ACTIVO=1;
    SELECT * FROM bbf_capacitacion_labor_detalle WHERE ID_CAPACITACION=P_ID_CAPACITACION AND ID_CAPACITACION_LABOR=P_ID_CAPACITACION_LABOR;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CAPACITACION_LABOR_GUARDAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CAPACITACION_LABOR_GUARDAR`(
    IN P_ID_CAPACITACION_LABOR INT, IN P_CODIGO VARCHAR(50), IN P_NOMBRE VARCHAR(150),
    IN P_DESCRIPCION VARCHAR(500), IN P_ORDEN INT, IN P_ACTIVO TINYINT
)
BEGIN
    IF NULLIF(TRIM(P_CODIGO),'') IS NULL OR NULLIF(TRIM(P_NOMBRE),'') IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Codigo y nombre de la labor son obligatorios.';
    END IF;
    IF P_ID_CAPACITACION_LABOR IS NULL OR P_ID_CAPACITACION_LABOR=0 THEN
        INSERT INTO bbf_capacitacion_labores(CODIGO,NOMBRE,DESCRIPCION,ORDEN,ACTIVO)
        VALUES(UPPER(TRIM(P_CODIGO)),TRIM(P_NOMBRE),NULLIF(TRIM(P_DESCRIPCION),''),IFNULL(P_ORDEN,0),IFNULL(P_ACTIVO,1));
        SET P_ID_CAPACITACION_LABOR=LAST_INSERT_ID();
    ELSE
        UPDATE bbf_capacitacion_labores SET CODIGO=UPPER(TRIM(P_CODIGO)),NOMBRE=TRIM(P_NOMBRE),
        DESCRIPCION=NULLIF(TRIM(P_DESCRIPCION),''),ORDEN=IFNULL(P_ORDEN,0),ACTIVO=IFNULL(P_ACTIVO,1)
        WHERE ID_CAPACITACION_LABOR=P_ID_CAPACITACION_LABOR;
    END IF;
    SELECT * FROM bbf_capacitacion_labores WHERE ID_CAPACITACION_LABOR=P_ID_CAPACITACION_LABOR;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CAPACITACION_MIS_REGISTROS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CAPACITACION_MIS_REGISTROS_LISTAR`(IN P_ID_USUARIO INT)
BEGIN
    SELECT P.ID_CAPACITACION_PARTICIPANTE,S.ID_CAPACITACION_SESION,S.CODIGO AS CODIGO_SESION,S.FECHA_INICIO,S.FECHA_FIN,
    S.ANIO_ISO,S.SEMANA_ISO,S.ESTADO AS ESTADO_SESION,C.ID_CAPACITACION,C.NOMBRE AS CAPACITACION,C.TIPO,
    P.ESTADO_ASISTENCIA,P.CONFIRMO_RECIBIDO,P.FECHA_CONFIRMACION,P.ESTADO_EVALUACION,
    R.PUNTAJE_FINAL,R.PUNTAJE_MINIMO_APLICADO,R.RESULTADO,R.REQUIERE_REINDUCCION,R.REQUIERE_COMPROMISO
    FROM bbf_usuarios U INNER JOIN bbf_capacitacion_participantes P ON P.ID_EMPLEADO=U.ID_EMPLEADO
    INNER JOIN bbf_capacitacion_sesiones S ON S.ID_CAPACITACION_SESION=P.ID_CAPACITACION_SESION
    INNER JOIN bbf_capacitaciones C ON C.ID_CAPACITACION=S.ID_CAPACITACION
    LEFT JOIN bbf_capacitacion_resultados R ON R.ID_CAPACITACION_PARTICIPANTE=P.ID_CAPACITACION_PARTICIPANTE
    WHERE U.ID_USUARIO=P_ID_USUARIO ORDER BY S.FECHA_INICIO DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CAPACITACION_PARTICIPANTE_AGREGAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CAPACITACION_PARTICIPANTE_AGREGAR`(
    IN P_ID_SESION INT, IN P_ID_EMPLEADO INT, IN P_OBSERVACIONES TEXT, IN P_ID_USUARIO INT
)
BEGIN
    DECLARE V_REQUIERE_EVALUACION TINYINT;
    IF NOT EXISTS(SELECT 1 FROM bbf_empleados WHERE ID_EMPLEADO=P_ID_EMPLEADO AND ELIMINADO=0) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El empleado no existe o fue eliminado.';
    END IF;
    SELECT C.REQUIERE_EVALUACION INTO V_REQUIERE_EVALUACION
    FROM bbf_capacitacion_sesiones S INNER JOIN bbf_capacitaciones C ON C.ID_CAPACITACION=S.ID_CAPACITACION
    WHERE S.ID_CAPACITACION_SESION=P_ID_SESION AND S.ESTADO<>'ANULADA' LIMIT 1;
    IF V_REQUIERE_EVALUACION IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La sesion no existe o esta anulada.'; END IF;
    INSERT INTO bbf_capacitacion_participantes(ID_CAPACITACION_SESION,ID_EMPLEADO,ESTADO_EVALUACION,OBSERVACIONES,ID_REGISTRADO_POR)
    VALUES(P_ID_SESION,P_ID_EMPLEADO,IF(V_REQUIERE_EVALUACION=1,'PENDIENTE','NO_APLICA'),NULLIF(TRIM(P_OBSERVACIONES),''),P_ID_USUARIO)
    ON DUPLICATE KEY UPDATE OBSERVACIONES=VALUES(OBSERVACIONES);
    SELECT * FROM bbf_capacitacion_participantes WHERE ID_CAPACITACION_SESION=P_ID_SESION AND ID_EMPLEADO=P_ID_EMPLEADO;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CAPACITACION_RESULTADO_REGISTRAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CAPACITACION_RESULTADO_REGISTRAR`(
    IN P_ID_PARTICIPANTE INT, IN P_FECHA_RESULTADO DATE, IN P_PUNTAJE_FINAL DECIMAL(10,2),
    IN P_PUNTAJE_MINIMO DECIMAL(10,2), IN P_RESULTADO VARCHAR(30), IN P_REQUIERE_REINDUCCION TINYINT,
    IN P_REQUIERE_COMPROMISO TINYINT, IN P_REGLA VARCHAR(500), IN P_OBSERVACIONES TEXT, IN P_ID_USUARIO INT
)
BEGIN
    DECLARE V_TOTAL DECIMAL(14,2); DECLARE V_RESULTADO VARCHAR(30);
    SELECT COALESCE(SUM(VALOR_OBTENIDO),0) INTO V_TOTAL FROM bbf_capacitacion_evaluaciones WHERE ID_CAPACITACION_PARTICIPANTE=P_ID_PARTICIPANTE;
    SET V_RESULTADO=UPPER(TRIM(IFNULL(P_RESULTADO,'')));
    IF V_RESULTADO='' THEN
        SET V_RESULTADO=CASE WHEN P_PUNTAJE_FINAL IS NULL OR P_PUNTAJE_MINIMO IS NULL THEN 'PENDIENTE'
        WHEN P_PUNTAJE_FINAL>=P_PUNTAJE_MINIMO THEN 'APROBADO' ELSE 'NO_APROBADO' END;
    END IF;
    IF V_RESULTADO NOT IN('PENDIENTE','APROBADO','NO_APROBADO','REQUIERE_REINDUCCION') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Resultado no valido.';
    END IF;
    INSERT INTO bbf_capacitacion_resultados(ID_CAPACITACION_PARTICIPANTE,FECHA_RESULTADO,TOTAL_ACUMULADO,PUNTAJE_FINAL,
    PUNTAJE_MINIMO_APLICADO,RESULTADO,REQUIERE_REINDUCCION,REQUIERE_COMPROMISO,REGLA_APLICADA,OBSERVACIONES,ID_REGISTRADO_POR)
    VALUES(P_ID_PARTICIPANTE,IFNULL(P_FECHA_RESULTADO,CURRENT_DATE),V_TOTAL,P_PUNTAJE_FINAL,P_PUNTAJE_MINIMO,V_RESULTADO,
    IFNULL(P_REQUIERE_REINDUCCION,V_RESULTADO IN('NO_APROBADO','REQUIERE_REINDUCCION')),
    IFNULL(P_REQUIERE_COMPROMISO,0),NULLIF(TRIM(P_REGLA),''),NULLIF(TRIM(P_OBSERVACIONES),''),P_ID_USUARIO)
    ON DUPLICATE KEY UPDATE FECHA_RESULTADO=VALUES(FECHA_RESULTADO),TOTAL_ACUMULADO=VALUES(TOTAL_ACUMULADO),
    PUNTAJE_FINAL=VALUES(PUNTAJE_FINAL),PUNTAJE_MINIMO_APLICADO=VALUES(PUNTAJE_MINIMO_APLICADO),RESULTADO=VALUES(RESULTADO),
    REQUIERE_REINDUCCION=VALUES(REQUIERE_REINDUCCION),REQUIERE_COMPROMISO=VALUES(REQUIERE_COMPROMISO),
    REGLA_APLICADA=VALUES(REGLA_APLICADA),OBSERVACIONES=VALUES(OBSERVACIONES),ID_REGISTRADO_POR=VALUES(ID_REGISTRADO_POR);
    UPDATE bbf_capacitacion_participantes SET ESTADO_EVALUACION=IF(V_RESULTADO='PENDIENTE','EN_PROCESO','EVALUADA')
    WHERE ID_CAPACITACION_PARTICIPANTE=P_ID_PARTICIPANTE;
    SELECT * FROM bbf_capacitacion_resultados WHERE ID_CAPACITACION_PARTICIPANTE=P_ID_PARTICIPANTE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CAPACITACION_SESIONES_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CAPACITACION_SESIONES_LISTAR`(
    IN P_ID_CAPACITACION INT, IN P_ANIO SMALLINT, IN P_SEMANA TINYINT, IN P_ESTADO VARCHAR(20)
)
BEGIN
    SELECT S.*,C.CODIGO AS CODIGO_CAPACITACION,C.NOMBRE AS CAPACITACION,C.TIPO,
    COUNT(DISTINCT P.ID_CAPACITACION_PARTICIPANTE) AS TOTAL_PARTICIPANTES,
    SUM(CASE WHEN P.ESTADO_EVALUACION='PENDIENTE' THEN 1 ELSE 0 END) AS EVALUACIONES_PENDIENTES
    FROM bbf_capacitacion_sesiones S
    INNER JOIN bbf_capacitaciones C ON C.ID_CAPACITACION=S.ID_CAPACITACION
    LEFT JOIN bbf_capacitacion_participantes P ON P.ID_CAPACITACION_SESION=S.ID_CAPACITACION_SESION
    WHERE (P_ID_CAPACITACION IS NULL OR P_ID_CAPACITACION=0 OR S.ID_CAPACITACION=P_ID_CAPACITACION)
      AND (P_ANIO IS NULL OR P_ANIO=0 OR S.ANIO_ISO=P_ANIO)
      AND (P_SEMANA IS NULL OR P_SEMANA=0 OR S.SEMANA_ISO=P_SEMANA)
      AND (NULLIF(TRIM(P_ESTADO),'') IS NULL OR S.ESTADO=UPPER(TRIM(P_ESTADO)))
    GROUP BY S.ID_CAPACITACION_SESION
    ORDER BY S.FECHA_INICIO DESC,S.ID_CAPACITACION_SESION DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CAPACITACION_SESION_CAMBIAR_ESTADO` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CAPACITACION_SESION_CAMBIAR_ESTADO`(
    IN P_ID_SESION INT, IN P_ESTADO VARCHAR(20), IN P_ID_USUARIO INT
)
BEGIN
    DECLARE V_ESTADO VARCHAR(20);
    SET V_ESTADO=UPPER(TRIM(P_ESTADO));
    IF V_ESTADO NOT IN('BORRADOR','PROGRAMADA','EN_EJECUCION','CERRADA','ANULADA') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Estado de sesion no valido.';
    END IF;
    IF V_ESTADO='CERRADA' AND EXISTS(
        SELECT 1 FROM bbf_capacitacion_participantes WHERE ID_CAPACITACION_SESION=P_ID_SESION AND ESTADO_EVALUACION IN('PENDIENTE','EN_PROCESO')
    ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='No se puede cerrar: existen evaluaciones pendientes.';
    END IF;
    UPDATE bbf_capacitacion_sesiones SET ESTADO=V_ESTADO,
    FECHA_CIERRE=CASE WHEN V_ESTADO='CERRADA' THEN CURRENT_TIMESTAMP ELSE FECHA_CIERRE END,
    ID_CERRADO_POR=CASE WHEN V_ESTADO='CERRADA' THEN P_ID_USUARIO ELSE ID_CERRADO_POR END
    WHERE ID_CAPACITACION_SESION=P_ID_SESION;
    SELECT * FROM bbf_capacitacion_sesiones WHERE ID_CAPACITACION_SESION=P_ID_SESION;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CAPACITACION_SESION_CREAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CAPACITACION_SESION_CREAR`(
    IN P_ID_CAPACITACION INT, IN P_FECHA_INICIO DATE, IN P_FECHA_FIN DATE,
    IN P_ID_INSTRUCTOR_USUARIO INT, IN P_INSTRUCTOR_EXTERNO VARCHAR(200),
    IN P_LUGAR VARCHAR(250), IN P_OBSERVACIONES TEXT, IN P_ID_USUARIO INT
)
BEGIN
    DECLARE V_CODIGO VARCHAR(60);
    IF P_FECHA_INICIO IS NULL OR P_FECHA_FIN IS NULL OR P_FECHA_FIN<P_FECHA_INICIO THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El rango de fechas de la sesion no es valido.';
    END IF;
    IF NOT EXISTS(SELECT 1 FROM bbf_capacitaciones WHERE ID_CAPACITACION=P_ID_CAPACITACION AND ACTIVO=1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La capacitacion no existe o esta inactiva.';
    END IF;
    SET V_CODIGO=CONCAT('CAP-',P_ID_CAPACITACION,'-',YEARWEEK(P_FECHA_INICIO,3),'-',DATE_FORMAT(P_FECHA_INICIO,'%m%d'));
    INSERT INTO bbf_capacitacion_sesiones(ID_CAPACITACION,CODIGO,FECHA_INICIO,FECHA_FIN,ANIO_ISO,SEMANA_ISO,
    ID_INSTRUCTOR_USUARIO,INSTRUCTOR_EXTERNO,LUGAR,ESTADO,OBSERVACIONES,ID_CREADO_POR)
    VALUES(P_ID_CAPACITACION,V_CODIGO,P_FECHA_INICIO,P_FECHA_FIN,
    YEAR(DATE_ADD(DATE_SUB(P_FECHA_INICIO,INTERVAL WEEKDAY(P_FECHA_INICIO) DAY),INTERVAL 3 DAY)),
    WEEK(P_FECHA_INICIO,3),P_ID_INSTRUCTOR_USUARIO,NULLIF(TRIM(P_INSTRUCTOR_EXTERNO),''),NULLIF(TRIM(P_LUGAR),''),'BORRADOR',
    NULLIF(TRIM(P_OBSERVACIONES),''),P_ID_USUARIO);
    SELECT * FROM bbf_capacitacion_sesiones WHERE ID_CAPACITACION_SESION=LAST_INSERT_ID();
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CAPACITACION_SESION_DETALLE` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CAPACITACION_SESION_DETALLE`(IN P_ID_SESION INT)
BEGIN
    SELECT S.*,C.NOMBRE AS CAPACITACION,C.TIPO,C.PUNTAJE_MINIMO,C.PUNTAJE_MAXIMO
    FROM bbf_capacitacion_sesiones S
    INNER JOIN bbf_capacitaciones C ON C.ID_CAPACITACION=S.ID_CAPACITACION
    WHERE S.ID_CAPACITACION_SESION=P_ID_SESION;

    SELECT P.*,E.NUMERO_DOCUMENTO,CONCAT_WS(' ',E.NOMBRES,E.APELLIDOS) AS EMPLEADO,E.ESTADO_EMPLEADO,
    R.ID_CAPACITACION_RESULTADO,R.TOTAL_ACUMULADO,R.PUNTAJE_FINAL,R.PUNTAJE_MINIMO_APLICADO,
    R.RESULTADO,R.REQUIERE_REINDUCCION,R.REQUIERE_COMPROMISO,
    CO.ID_CAPACITACION_COMPROMISO,CO.ESTADO AS ESTADO_COMPROMISO
    FROM bbf_capacitacion_participantes P
    INNER JOIN bbf_empleados E ON E.ID_EMPLEADO=P.ID_EMPLEADO
    LEFT JOIN bbf_capacitacion_resultados R ON R.ID_CAPACITACION_PARTICIPANTE=P.ID_CAPACITACION_PARTICIPANTE
    LEFT JOIN bbf_capacitacion_compromisos CO ON CO.ID_CAPACITACION_RESULTADO=R.ID_CAPACITACION_RESULTADO
    WHERE P.ID_CAPACITACION_SESION=P_ID_SESION
    ORDER BY E.NOMBRES,E.APELLIDOS;

    SELECT EV.*,L.CODIGO AS CODIGO_LABOR,L.NOMBRE AS LABOR,P.ID_EMPLEADO
    FROM bbf_capacitacion_evaluaciones EV
    INNER JOIN bbf_capacitacion_labores L ON L.ID_CAPACITACION_LABOR=EV.ID_CAPACITACION_LABOR
    INNER JOIN bbf_capacitacion_participantes P ON P.ID_CAPACITACION_PARTICIPANTE=EV.ID_CAPACITACION_PARTICIPANTE
    WHERE P.ID_CAPACITACION_SESION=P_ID_SESION
    ORDER BY P.ID_EMPLEADO,L.ORDEN,EV.FECHA_EVALUACION;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CARGOS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CARGOS_LISTAR`(
    IN P_SOLO_ACTIVOS TINYINT
)
BEGIN
    SELECT
        ID_CARGO,
        NOMBRE,
        DESCRIPCION,
        ACTIVO,
        CREATED_AT,
        UPDATED_AT
    FROM bbf_cargos
    WHERE P_SOLO_ACTIVOS = 0 OR ACTIVO = 1
    ORDER BY NOMBRE ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CONTRATACION_ALERTAS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CONTRATACION_ALERTAS_LISTAR`(
    IN P_DIAS_ANTES INT
)
BEGIN
    DECLARE V_DIAS_ANTES INT DEFAULT 30;

    SET V_DIAS_ANTES = IFNULL(P_DIAS_ANTES, 30);

    SELECT
        EC.ID_EMPLEADO_CONTRATO,
        EC.ID_EMPLEADO,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS) AS NOMBRE_COMPLETO,
        E.NUMERO_DOCUMENTO,
        E.CORREO,
        E.TELEFONO,

        TC.NOMBRE AS TIPO_CONTRATO,
        CP.NOMBRE_PLANTILLA,

        EC.NUMERO_CONTRATO,
        EC.FECHA_INICIO,
        EC.FECHA_FIN,
        EC.ESTADO_CONTRATO,

        A.NOMBRE AS AREA,
        C.NOMBRE AS CARGO,

        DATEDIFF(EC.FECHA_FIN, CURRENT_DATE()) AS DIAS_PARA_VENCER,

        CASE
            WHEN EC.FECHA_FIN < CURRENT_DATE() THEN 'VENCIDO'
            WHEN DATEDIFF(EC.FECHA_FIN, CURRENT_DATE()) <= V_DIAS_ANTES THEN 'PROXIMO_A_VENCER'
            ELSE 'VIGENTE'
        END AS TIPO_ALERTA

    FROM bbf_empleado_contratos EC
    INNER JOIN bbf_empleados E
        ON E.ID_EMPLEADO = EC.ID_EMPLEADO
       AND IFNULL(E.ELIMINADO, 0) = 0
    LEFT JOIN bbf_tipos_contrato TC
        ON TC.ID_TIPO_CONTRATO = EC.ID_TIPO_CONTRATO
    LEFT JOIN bbf_contrato_plantillas CP
        ON CP.ID_PLANTILLA_CONTRATO = EC.ID_PLANTILLA_CONTRATO
    LEFT JOIN bbf_areas A
        ON A.ID_AREA = EC.ID_AREA
    LEFT JOIN bbf_cargos C
        ON C.ID_CARGO = EC.ID_CARGO
    WHERE IFNULL(EC.ELIMINADO, 0) = 0
      AND EC.FECHA_FIN IS NOT NULL
      AND EC.ESTADO_CONTRATO = 'ACTIVO'
      AND EC.FECHA_FIN <= DATE_ADD(CURRENT_DATE(), INTERVAL V_DIAS_ANTES DAY)
    ORDER BY EC.FECHA_FIN ASC, NOMBRE_COMPLETO ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CONTRATACION_CONTRATOS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CONTRATACION_CONTRATOS_LISTAR`(
    IN P_ID_EMPLEADO INT
)
BEGIN

    SELECT
        EC.ID_EMPLEADO_CONTRATO,

        EC.ID_EMPLEADO,

        EC.ID_TIPO_CONTRATO,

        TC.NOMBRE
            AS TIPO_CONTRATO,

        EC.ID_PLANTILLA_CONTRATO,

        CP.NOMBRE_PLANTILLA,

        CP.CODIGO_FORMATO,

        CP.VERSION_FORMATO,

        CP.FECHA_VIGENCIA,

        CP.ARCHIVO_PLANTILLA_URL,

        CP.ARCHIVO_PLANTILLA_RUTA,

        CP.FORMATO_SALIDA_DEFAULT,

        CP.CONFIG_CAMPOS_JSON,

        CP.VALORES_DEFAULT_JSON,

        EC.ID_AREA,

        A.NOMBRE
            AS AREA,

        EC.ID_CARGO,

        C.NOMBRE
            AS CARGO,

        EC.FECHA_INICIO,

        EC.FECHA_FIN,

        EC.DURACION_MESES,

        EC.SALARIO_BASE,

        EC.AUXILIO_TRANSPORTE,

        EC.PERIODO_PAGO,

        EC.LUGAR_LABORES,

        EC.NUMERO_CONTRATO,

        EC.TIPO_CARGO_CONTRATO,

        EC.OBJETO_OBRA_LABOR,

        EC.PRORROGA_DIAS,

        EC.CLAUSULA_FUNCIONES,

        EC.JORNADA_LABORAL,

        EC.PERIODO_PRUEBA_DIAS,

        EC.ESTADO_CONTRATO,

        EC.ARCHIVO_CONTRATO_URL,

        -- =============================================================
        -- NUEVO
        -- =============================================================

        EC.FECHA_FIRMA,


        CASE

            WHEN EXISTS (

                SELECT 1

                FROM bbf_empleado_documentos D

                INNER JOIN bbf_tipos_documento_laboral TD
                    ON TD.ID_TIPO_DOCUMENTO_LABORAL =
                       D.ID_TIPO_DOCUMENTO_LABORAL

                WHERE D.ID_EMPLEADO_CONTRATO =
                      EC.ID_EMPLEADO_CONTRATO

                  AND IFNULL(
                      D.ELIMINADO,
                      0
                  ) = 0

                  AND D.ESTADO_DOCUMENTO
                      IN (
                          'CARGADO',
                          'VALIDADO'
                      )

                  AND LOWER(TD.NOMBRE) =
                      LOWER('Contrato firmado')
            )

            THEN 1

            ELSE 0

        END AS CONTRATO_FIRMADO,


        EC.OBSERVACIONES,

        EC.ID_REGISTRADO_POR,

        EC.CREATED_AT,

        EC.UPDATED_AT,


        -- =============================================================
        -- DÍAS PARA VENCIMIENTO
        -- =============================================================

        CASE

            WHEN EC.FECHA_FIN IS NULL
                THEN NULL

            ELSE DATEDIFF(
                EC.FECHA_FIN,
                CURRENT_DATE()
            )

        END AS DIAS_PARA_VENCER,


        -- =============================================================
        -- ESTADO DE VENCIMIENTO
        -- =============================================================

        CASE

            WHEN EC.FECHA_FIN IS NULL
                THEN 'SIN_VENCIMIENTO'

            WHEN EC.FECHA_FIN < CURRENT_DATE()
                THEN 'VENCIDO'

            WHEN DATEDIFF(
                EC.FECHA_FIN,
                CURRENT_DATE()
            ) <= 30
                THEN 'PROXIMO_A_VENCER'

            ELSE 'VIGENTE'

        END AS ESTADO_VENCIMIENTO


    FROM bbf_empleado_contratos EC


    LEFT JOIN bbf_tipos_contrato TC
        ON TC.ID_TIPO_CONTRATO =
           EC.ID_TIPO_CONTRATO


    LEFT JOIN bbf_contrato_plantillas CP
        ON CP.ID_PLANTILLA_CONTRATO =
           EC.ID_PLANTILLA_CONTRATO


    LEFT JOIN bbf_areas A
        ON A.ID_AREA =
           EC.ID_AREA


    LEFT JOIN bbf_cargos C
        ON C.ID_CARGO =
           EC.ID_CARGO


    WHERE EC.ID_EMPLEADO =
          P_ID_EMPLEADO

      AND IFNULL(
          EC.ELIMINADO,
          0
      ) = 0


    ORDER BY
        EC.FECHA_INICIO DESC,
        EC.ID_EMPLEADO_CONTRATO DESC;


END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CONTRATACION_CONTRATO_ARCHIVO_ACTUALIZAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CONTRATACION_CONTRATO_ARCHIVO_ACTUALIZAR`(
    IN P_ID_EMPLEADO_CONTRATO INT,
    IN P_ARCHIVO_CONTRATO_URL VARCHAR(500),
    IN P_ID_USUARIO INT
)
BEGIN
    DECLARE V_EXISTE INT DEFAULT 0;

    SELECT COUNT(*)
    INTO V_EXISTE
    FROM bbf_empleado_contratos
    WHERE ID_EMPLEADO_CONTRATO = P_ID_EMPLEADO_CONTRATO
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_EXISTE = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El contrato del empleado no existe o fue eliminado.';
    END IF;

    IF P_ARCHIVO_CONTRATO_URL IS NULL OR TRIM(P_ARCHIVO_CONTRATO_URL) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La URL del archivo de contrato es obligatoria.';
    END IF;

    UPDATE bbf_empleado_contratos
    SET
        ARCHIVO_CONTRATO_URL = P_ARCHIVO_CONTRATO_URL,
        UPDATED_AT = CURRENT_TIMESTAMP
    WHERE ID_EMPLEADO_CONTRATO = P_ID_EMPLEADO_CONTRATO;

    SELECT
        ID_EMPLEADO_CONTRATO,
        ID_EMPLEADO,
        ARCHIVO_CONTRATO_URL,
        ESTADO_CONTRATO
    FROM bbf_empleado_contratos
    WHERE ID_EMPLEADO_CONTRATO = P_ID_EMPLEADO_CONTRATO
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CONTRATACION_CONTRATO_CREAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CONTRATACION_CONTRATO_CREAR`(
    IN P_ID_EMPLEADO INT,
    IN P_ID_TIPO_CONTRATO INT,
    IN P_ID_PLANTILLA_CONTRATO INT,
    IN P_ID_AREA INT,
    IN P_ID_CARGO INT,
    IN P_FECHA_INICIO DATE,
    IN P_FECHA_FIN DATE,
    IN P_DURACION_MESES INT,
    IN P_SALARIO_BASE DECIMAL(12,2),
    IN P_AUXILIO_TRANSPORTE TINYINT,
    IN P_PERIODO_PAGO VARCHAR(100),
    IN P_LUGAR_LABORES VARCHAR(250),
    IN P_NUMERO_CONTRATO VARCHAR(100),
    IN P_TIPO_CARGO_CONTRATO VARCHAR(30),
    IN P_OBJETO_OBRA_LABOR TEXT,
    IN P_PRORROGA_DIAS INT,
    IN P_CLAUSULA_FUNCIONES TEXT,
    IN P_JORNADA_LABORAL VARCHAR(150),
    IN P_PERIODO_PRUEBA_DIAS INT,
    IN P_ESTADO_CONTRATO VARCHAR(30),
    IN P_ARCHIVO_CONTRATO_URL VARCHAR(500),
    IN P_OBSERVACIONES TEXT,
    IN P_ID_REGISTRADO_POR INT
)
BEGIN
    DECLARE V_EXISTE INT DEFAULT 0;
    DECLARE V_ID_EMPLEADO_CONTRATO INT;
    DECLARE V_TIPO_CONTRATO_PLANTILLA INT;

    SELECT COUNT(*)
    INTO V_EXISTE
    FROM bbf_empleados
    WHERE ID_EMPLEADO = P_ID_EMPLEADO
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_EXISTE = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El empleado no existe o fue eliminado.';
    END IF;

    SELECT COUNT(*)
    INTO V_EXISTE
    FROM bbf_tipos_contrato
    WHERE ID_TIPO_CONTRATO = P_ID_TIPO_CONTRATO
      AND ACTIVO = 1;

    IF V_EXISTE = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El tipo de contrato no existe o está inactivo.';
    END IF;

    IF P_ID_PLANTILLA_CONTRATO IS NOT NULL THEN
        SELECT COUNT(*)
        INTO V_EXISTE
        FROM bbf_contrato_plantillas
        WHERE ID_PLANTILLA_CONTRATO = P_ID_PLANTILLA_CONTRATO
          AND IFNULL(ELIMINADO, 0) = 0
          AND ACTIVO = 1;

        IF V_EXISTE = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La plantilla de contrato no existe o está inactiva.';
        END IF;

        SELECT ID_TIPO_CONTRATO
        INTO V_TIPO_CONTRATO_PLANTILLA
        FROM bbf_contrato_plantillas
        WHERE ID_PLANTILLA_CONTRATO = P_ID_PLANTILLA_CONTRATO
        LIMIT 1;

        IF V_TIPO_CONTRATO_PLANTILLA <> P_ID_TIPO_CONTRATO THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La plantilla seleccionada no corresponde al tipo de contrato.';
        END IF;
    END IF;

    IF P_FECHA_INICIO IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La fecha de inicio del contrato es obligatoria.';
    END IF;

    IF P_FECHA_FIN IS NOT NULL AND P_FECHA_FIN < P_FECHA_INICIO THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La fecha de finalización no puede ser menor a la fecha de inicio.';
    END IF;

    IF P_ESTADO_CONTRATO IS NOT NULL
       AND P_ESTADO_CONTRATO NOT IN ('ACTIVO','VENCIDO','RENOVADO','FINALIZADO','ANULADO') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Estado de contrato no válido.';
    END IF;

    IF P_TIPO_CARGO_CONTRATO IS NOT NULL
       AND P_TIPO_CARGO_CONTRATO NOT IN ('ADMINISTRATIVO','OPERATIVO','OTRO') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tipo de cargo del contrato no válido.';
    END IF;

    INSERT INTO bbf_empleado_contratos (
        ID_EMPLEADO,
        ID_TIPO_CONTRATO,
        ID_PLANTILLA_CONTRATO,
        ID_AREA,
        ID_CARGO,
        FECHA_INICIO,
        FECHA_FIN,
        DURACION_MESES,
        SALARIO_BASE,
        AUXILIO_TRANSPORTE,
        PERIODO_PAGO,
        LUGAR_LABORES,
        NUMERO_CONTRATO,
        TIPO_CARGO_CONTRATO,
        OBJETO_OBRA_LABOR,
        PRORROGA_DIAS,
        CLAUSULA_FUNCIONES,
        JORNADA_LABORAL,
        PERIODO_PRUEBA_DIAS,
        ESTADO_CONTRATO,
        ARCHIVO_CONTRATO_URL,
        OBSERVACIONES,
        ID_REGISTRADO_POR
    )
    VALUES (
        P_ID_EMPLEADO,
        P_ID_TIPO_CONTRATO,
        P_ID_PLANTILLA_CONTRATO,
        P_ID_AREA,
        P_ID_CARGO,
        P_FECHA_INICIO,
        P_FECHA_FIN,
        P_DURACION_MESES,
        P_SALARIO_BASE,
        P_AUXILIO_TRANSPORTE,
        P_PERIODO_PAGO,
        P_LUGAR_LABORES,
        P_NUMERO_CONTRATO,
        P_TIPO_CARGO_CONTRATO,
        P_OBJETO_OBRA_LABOR,
        P_PRORROGA_DIAS,
        P_CLAUSULA_FUNCIONES,
        P_JORNADA_LABORAL,
        P_PERIODO_PRUEBA_DIAS,
        IFNULL(P_ESTADO_CONTRATO, 'ACTIVO'),
        P_ARCHIVO_CONTRATO_URL,
        P_OBSERVACIONES,
        P_ID_REGISTRADO_POR
    );

    SET V_ID_EMPLEADO_CONTRATO = LAST_INSERT_ID();

    UPDATE bbf_empleados
    SET
        ID_TIPO_CONTRATO = P_ID_TIPO_CONTRATO,
        ID_AREA = IFNULL(P_ID_AREA, ID_AREA),
        ID_CARGO = IFNULL(P_ID_CARGO, ID_CARGO),
        FECHA_INGRESO = IFNULL(FECHA_INGRESO, P_FECHA_INICIO),
        UPDATED_AT = CURRENT_TIMESTAMP
    WHERE ID_EMPLEADO = P_ID_EMPLEADO;

    SELECT
        V_ID_EMPLEADO_CONTRATO AS ID_EMPLEADO_CONTRATO,
        P_ID_EMPLEADO AS ID_EMPLEADO,
        P_ID_TIPO_CONTRATO AS ID_TIPO_CONTRATO,
        P_ID_PLANTILLA_CONTRATO AS ID_PLANTILLA_CONTRATO,
        IFNULL(P_ESTADO_CONTRATO, 'ACTIVO') AS ESTADO_CONTRATO;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CONTRATACION_CONTRATO_DATOS_GENERAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CONTRATACION_CONTRATO_DATOS_GENERAR`(
    IN P_ID_EMPLEADO_CONTRATO INT
)
BEGIN
    SELECT
        EC.ID_EMPLEADO_CONTRATO,
        EC.ID_EMPLEADO,

        E.ID_ASPIRANTE_ORIGEN,
        E.NUMERO_DOCUMENTO,
        E.NOMBRES,
        E.APELLIDOS,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS) AS NOMBRE_COMPLETO,
        E.CORREO,
        E.TELEFONO,
        E.FECHA_INGRESO,
        E.ESTADO_EMPLEADO,

        TD.NOMBRE AS TIPO_DOCUMENTO,

        FI.FECHA_NACIMIENTO,
        FI.LUGAR_NACIMIENTO,
        FI.NACIONALIDAD,
        FI.DEPARTAMENTO_NACIMIENTO,
        FI.CIUDAD_RESIDENCIA,
        FI.DEPARTAMENTO_RESIDENCIA,
        FI.DIRECCION_RESIDENCIA,
        FI.TELEFONO_ALTERNO,
        FI.CORREO_PERSONAL,
        FI.ESTADO_CIVIL,
        FI.NIVEL_EDUCATIVO,
        FI.PERSONAS_A_CARGO,
        FI.NUMERO_HIJOS,

        EC.ID_TIPO_CONTRATO,
        TC.NOMBRE AS TIPO_CONTRATO,

        EC.ID_PLANTILLA_CONTRATO,
        CP.NOMBRE_PLANTILLA,
        CP.CODIGO_FORMATO,
        CP.VERSION_FORMATO,
        CP.FECHA_VIGENCIA,
        CP.TIPO_CARGO_CONTRATO AS TIPO_CARGO_PLANTILLA,
        CP.ARCHIVO_PLANTILLA_URL,
        CP.ARCHIVO_PLANTILLA_RUTA,
        CP.FORMATO_SALIDA_DEFAULT,
        CP.CONFIG_CAMPOS_JSON,
        CP.VALORES_DEFAULT_JSON,

        EC.ID_AREA,
        A.NOMBRE AS AREA,
        EC.ID_CARGO,
        C.NOMBRE AS CARGO,

        EC.FECHA_INICIO,
        EC.FECHA_FIN,
        EC.DURACION_MESES,
        EC.SALARIO_BASE,
        EC.AUXILIO_TRANSPORTE,
        EC.PERIODO_PAGO,
        EC.LUGAR_LABORES,
        EC.NUMERO_CONTRATO,
        EC.TIPO_CARGO_CONTRATO,
        EC.OBJETO_OBRA_LABOR,
        EC.PRORROGA_DIAS,
        EC.CLAUSULA_FUNCIONES,
        EC.JORNADA_LABORAL,
        EC.PERIODO_PRUEBA_DIAS,
        EC.ESTADO_CONTRATO,
        EC.ARCHIVO_CONTRATO_URL,
        EC.OBSERVACIONES,

        CURRENT_DATE() AS FECHA_GENERACION

    FROM bbf_empleado_contratos EC
    INNER JOIN bbf_empleados E
        ON E.ID_EMPLEADO = EC.ID_EMPLEADO
       AND IFNULL(E.ELIMINADO, 0) = 0
    LEFT JOIN bbf_tipos_documento TD
        ON TD.ID_TIPO_DOCUMENTO = E.ID_TIPO_DOCUMENTO
    LEFT JOIN bbf_empleado_ficha_ingreso FI
        ON FI.ID_EMPLEADO = E.ID_EMPLEADO
       AND IFNULL(FI.ELIMINADO, 0) = 0
    LEFT JOIN bbf_tipos_contrato TC
        ON TC.ID_TIPO_CONTRATO = EC.ID_TIPO_CONTRATO
    LEFT JOIN bbf_contrato_plantillas CP
        ON CP.ID_PLANTILLA_CONTRATO = EC.ID_PLANTILLA_CONTRATO
    LEFT JOIN bbf_areas A
        ON A.ID_AREA = EC.ID_AREA
    LEFT JOIN bbf_cargos C
        ON C.ID_CARGO = EC.ID_CARGO
    WHERE EC.ID_EMPLEADO_CONTRATO = P_ID_EMPLEADO_CONTRATO
      AND IFNULL(EC.ELIMINADO, 0) = 0
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CONTRATACION_CONTRATO_FIRMADO_REGISTRAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CONTRATACION_CONTRATO_FIRMADO_REGISTRAR`(
    IN P_ID_EMPLEADO_CONTRATO INT,
    IN P_FECHA_FIRMA DATE,

    IN P_NOMBRE_ARCHIVO VARCHAR(255),
    IN P_NOMBRE_ORIGINAL VARCHAR(255),

    IN P_ARCHIVO_URL VARCHAR(500),
    IN P_ARCHIVO_RUTA VARCHAR(500),

    IN P_MIME_TYPE VARCHAR(100),
    IN P_PESO_BYTES BIGINT,

    IN P_OBSERVACIONES TEXT,
    IN P_ID_USUARIO INT
)
BEGIN

    DECLARE V_EXISTE_CONTRATO INT DEFAULT 0;
    DECLARE V_ID_EMPLEADO INT DEFAULT NULL;

    DECLARE V_ID_TIPO_DOCUMENTO INT DEFAULT NULL;

    DECLARE V_ID_DOCUMENTO_EXISTENTE INT DEFAULT NULL;
    DECLARE V_ID_DOCUMENTO_RESULTADO INT DEFAULT NULL;


    -- ================================================================
    -- MANEJO DE ERRORES
    -- ================================================================

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;


    -- ================================================================
    -- VALIDAR QUE EL CONTRATO EXISTA
    -- ================================================================

    SELECT
        COUNT(*),
        MAX(ID_EMPLEADO)
    INTO
        V_EXISTE_CONTRATO,
        V_ID_EMPLEADO

    FROM bbf_empleado_contratos

    WHERE ID_EMPLEADO_CONTRATO = P_ID_EMPLEADO_CONTRATO
      AND IFNULL(ELIMINADO, 0) = 0;


    IF V_EXISTE_CONTRATO = 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'El contrato indicado no existe o fue eliminado.';

    END IF;


    -- ================================================================
    -- VALIDAR FECHA DE FIRMA
    -- ================================================================

    IF P_FECHA_FIRMA IS NULL THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'La fecha de firma del contrato es obligatoria.';

    END IF;


    -- ================================================================
    -- VALIDAR NOMBRE DEL DOCUMENTO
    -- ================================================================

    IF P_NOMBRE_ARCHIVO IS NULL
       OR TRIM(P_NOMBRE_ARCHIVO) = '' THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'El nombre del documento es obligatorio.';

    END IF;


    -- ================================================================
    -- VALIDAR ORIGEN DEL DOCUMENTO
    --
    -- Debe existir:
    --      ARCHIVO_URL
    -- o
    --      ARCHIVO_RUTA
    --
    -- No pueden existir ambos simultáneamente.
    -- ================================================================

    IF (
        (
            P_ARCHIVO_URL IS NULL
            OR TRIM(P_ARCHIVO_URL) = ''
        )
        AND
        (
            P_ARCHIVO_RUTA IS NULL
            OR TRIM(P_ARCHIVO_RUTA) = ''
        )
    ) THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Debe registrar una URL externa o cargar un archivo físico.';

    END IF;


    IF (
        (
            P_ARCHIVO_URL IS NOT NULL
            AND TRIM(P_ARCHIVO_URL) <> ''
        )
        AND
        (
            P_ARCHIVO_RUTA IS NOT NULL
            AND TRIM(P_ARCHIVO_RUTA) <> ''
        )
    ) THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Debe utilizar únicamente URL externa o archivo físico, no ambos.';

    END IF;


    -- ================================================================
    -- OBTENER TIPO DOCUMENTAL:
    -- "Contrato firmado"
    --
    -- No se quema ID = 3 para evitar dependencia directa del catálogo.
    -- ================================================================

    SELECT
        ID_TIPO_DOCUMENTO_LABORAL

    INTO
        V_ID_TIPO_DOCUMENTO

    FROM bbf_tipos_documento_laboral

    WHERE LOWER(NOMBRE) = LOWER('Contrato firmado')
      AND ACTIVO = 1

    LIMIT 1;


    IF V_ID_TIPO_DOCUMENTO IS NULL THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'No existe el tipo documental Contrato firmado.';

    END IF;


    -- ================================================================
    -- INICIAR TRANSACCIÓN
    -- ================================================================

    START TRANSACTION;


    -- ================================================================
    -- ACTUALIZAR FECHA REAL DE FIRMA DEL CONTRATO
    -- ================================================================

    UPDATE bbf_empleado_contratos

    SET
        FECHA_FIRMA = P_FECHA_FIRMA,
        UPDATED_AT = CURRENT_TIMESTAMP

    WHERE ID_EMPLEADO_CONTRATO =
          P_ID_EMPLEADO_CONTRATO;


    -- ================================================================
    -- VERIFICAR SI YA EXISTE SOPORTE DE CONTRATO FIRMADO
    -- PARA ESTE CONTRATO ESPECÍFICO
    -- ================================================================

    SELECT
        MAX(ID_EMPLEADO_DOCUMENTO)

    INTO
        V_ID_DOCUMENTO_EXISTENTE

    FROM bbf_empleado_documentos

    WHERE ID_EMPLEADO_CONTRATO =
          P_ID_EMPLEADO_CONTRATO

      AND ID_TIPO_DOCUMENTO_LABORAL =
          V_ID_TIPO_DOCUMENTO

      AND IFNULL(ELIMINADO, 0) = 0;


    -- ================================================================
    -- SI YA EXISTE EL DOCUMENTO, ACTUALIZARLO
    -- ================================================================

    IF V_ID_DOCUMENTO_EXISTENTE IS NOT NULL THEN


        UPDATE bbf_empleado_documentos

        SET
            ID_EMPLEADO =
                V_ID_EMPLEADO,

            NOMBRE_ARCHIVO =
                P_NOMBRE_ARCHIVO,

            NOMBRE_ORIGINAL =
                P_NOMBRE_ORIGINAL,

            ARCHIVO_URL =
                NULLIF(
                    TRIM(P_ARCHIVO_URL),
                    ''
                ),

            ARCHIVO_RUTA =
                NULLIF(
                    TRIM(P_ARCHIVO_RUTA),
                    ''
                ),

            MIME_TYPE =
                P_MIME_TYPE,

            PESO_BYTES =
                P_PESO_BYTES,

            FECHA_CARGA =
                CURRENT_TIMESTAMP,

            ESTADO_DOCUMENTO =
                'CARGADO',

            OBSERVACIONES =
                P_OBSERVACIONES,

            ID_CARGADO_POR =
                P_ID_USUARIO,

            ID_VALIDADO_POR =
                NULL,

            FECHA_VALIDACION =
                NULL,

            ELIMINADO =
                0,

            UPDATED_AT =
                CURRENT_TIMESTAMP

        WHERE ID_EMPLEADO_DOCUMENTO =
              V_ID_DOCUMENTO_EXISTENTE;


        SET V_ID_DOCUMENTO_RESULTADO =
            V_ID_DOCUMENTO_EXISTENTE;


    ELSE


        -- ============================================================
        -- SI NO EXISTE EL DOCUMENTO, CREARLO
        -- ============================================================

        INSERT INTO bbf_empleado_documentos (
            ID_EMPLEADO,
            ID_EMPLEADO_CONTRATO,
            ID_TIPO_DOCUMENTO_LABORAL,

            NOMBRE_ARCHIVO,
            NOMBRE_ORIGINAL,

            ARCHIVO_URL,
            ARCHIVO_RUTA,

            MIME_TYPE,
            PESO_BYTES,

            FECHA_CARGA,

            ESTADO_DOCUMENTO,

            OBSERVACIONES,

            ID_CARGADO_POR,

            ELIMINADO
        )
        VALUES (
            V_ID_EMPLEADO,
            P_ID_EMPLEADO_CONTRATO,
            V_ID_TIPO_DOCUMENTO,

            P_NOMBRE_ARCHIVO,
            P_NOMBRE_ORIGINAL,

            NULLIF(
                TRIM(P_ARCHIVO_URL),
                ''
            ),

            NULLIF(
                TRIM(P_ARCHIVO_RUTA),
                ''
            ),

            P_MIME_TYPE,
            P_PESO_BYTES,

            CURRENT_TIMESTAMP,

            'CARGADO',

            P_OBSERVACIONES,

            P_ID_USUARIO,

            0
        );


        SET V_ID_DOCUMENTO_RESULTADO =
            LAST_INSERT_ID();


    END IF;


    -- ================================================================
    -- CONFIRMAR TRANSACCIÓN
    -- ================================================================

    COMMIT;


    -- ================================================================
    -- RESPUESTA
    -- ================================================================

    SELECT
        EC.ID_EMPLEADO_CONTRATO,

        EC.ID_EMPLEADO,

        EC.NUMERO_CONTRATO,

        EC.FECHA_FIRMA,

        V_ID_DOCUMENTO_RESULTADO
            AS ID_EMPLEADO_DOCUMENTO,

        D.NOMBRE_ARCHIVO,

        D.NOMBRE_ORIGINAL,

        D.ARCHIVO_URL,

        D.ARCHIVO_RUTA,

        D.ESTADO_DOCUMENTO,

        D.OBSERVACIONES,

        'FIRMADO'
            AS ESTADO_FIRMA

    FROM bbf_empleado_contratos EC

    INNER JOIN bbf_empleado_documentos D
        ON D.ID_EMPLEADO_DOCUMENTO =
           V_ID_DOCUMENTO_RESULTADO

    WHERE EC.ID_EMPLEADO_CONTRATO =
          P_ID_EMPLEADO_CONTRATO;


END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CONTRATACION_DOCUMENTOS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CONTRATACION_DOCUMENTOS_LISTAR`(
    IN P_ID_EMPLEADO INT
)
BEGIN

    SELECT
        D.ID_EMPLEADO_DOCUMENTO,

        D.ID_EMPLEADO,

        -- NUEVO
        D.ID_EMPLEADO_CONTRATO,

        D.ID_TIPO_DOCUMENTO_LABORAL,

        TD.NOMBRE
            AS TIPO_DOCUMENTO_LABORAL,

        TD.OBLIGATORIO,

        TD.REQUIERE_VENCIMIENTO,

        D.NOMBRE_ARCHIVO,

        -- NUEVO
        D.NOMBRE_ORIGINAL,

        D.ARCHIVO_URL,

        -- NUEVO
        D.ARCHIVO_RUTA,

        D.MIME_TYPE,

        D.PESO_BYTES,

        D.FECHA_CARGA,

        D.FECHA_VENCIMIENTO,

        D.ESTADO_DOCUMENTO,

        D.OBSERVACIONES,

        D.ID_CARGADO_POR,

        UC.NOMBRE_USUARIO
            AS CARGADO_POR,

        D.ID_VALIDADO_POR,

        UV.NOMBRE_USUARIO
            AS VALIDADO_POR,

        D.FECHA_VALIDACION,


        -- =============================================================
        -- DOCUMENTO VENCIDO
        -- =============================================================

        CASE

            WHEN D.FECHA_VENCIMIENTO IS NOT NULL
             AND D.FECHA_VENCIMIENTO < CURRENT_DATE()

            THEN 1

            ELSE 0

        END AS VENCIDO,


        -- =============================================================
        -- PRÓXIMO A VENCER
        -- =============================================================

        CASE

            WHEN D.FECHA_VENCIMIENTO IS NOT NULL

             AND D.FECHA_VENCIMIENTO
                 BETWEEN CURRENT_DATE()
                 AND DATE_ADD(
                     CURRENT_DATE(),
                     INTERVAL 30 DAY
                 )

            THEN 1

            ELSE 0

        END AS PROXIMO_VENCER,


        D.CREATED_AT,

        D.UPDATED_AT


    FROM bbf_empleado_documentos D


    INNER JOIN bbf_tipos_documento_laboral TD
        ON TD.ID_TIPO_DOCUMENTO_LABORAL =
           D.ID_TIPO_DOCUMENTO_LABORAL


    LEFT JOIN bbf_usuarios UC
        ON UC.ID_USUARIO =
           D.ID_CARGADO_POR


    LEFT JOIN bbf_usuarios UV
        ON UV.ID_USUARIO =
           D.ID_VALIDADO_POR


    WHERE D.ID_EMPLEADO =
          P_ID_EMPLEADO

      AND IFNULL(
          D.ELIMINADO,
          0
      ) = 0


    ORDER BY
        TD.OBLIGATORIO DESC,
        TD.NOMBRE ASC,
        D.FECHA_CARGA DESC;


END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CONTRATACION_DOCUMENTO_REGISTRAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CONTRATACION_DOCUMENTO_REGISTRAR`(
    IN P_ID_EMPLEADO INT,
    IN P_ID_TIPO_DOCUMENTO_LABORAL INT,
    IN P_NOMBRE_ARCHIVO VARCHAR(255),
    IN P_ARCHIVO_URL VARCHAR(500),
    IN P_MIME_TYPE VARCHAR(100),
    IN P_PESO_BYTES BIGINT,
    IN P_FECHA_VENCIMIENTO DATE,
    IN P_ESTADO_DOCUMENTO VARCHAR(50),
    IN P_OBSERVACIONES TEXT,
    IN P_ID_CARGADO_POR INT
)
BEGIN
    DECLARE V_EXISTE_EMPLEADO INT DEFAULT 0;
    DECLARE V_ID_DOCUMENTO INT;

    SELECT COUNT(*)
    INTO V_EXISTE_EMPLEADO
    FROM bbf_empleados
    WHERE ID_EMPLEADO = P_ID_EMPLEADO
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_EXISTE_EMPLEADO = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El empleado no existe o fue eliminado.';
    END IF;

    INSERT INTO bbf_empleado_documentos (
        ID_EMPLEADO,
        ID_TIPO_DOCUMENTO_LABORAL,
        NOMBRE_ARCHIVO,
        ARCHIVO_URL,
        MIME_TYPE,
        PESO_BYTES,
        FECHA_VENCIMIENTO,
        ESTADO_DOCUMENTO,
        OBSERVACIONES,
        ID_CARGADO_POR
    )
    VALUES (
        P_ID_EMPLEADO,
        P_ID_TIPO_DOCUMENTO_LABORAL,
        P_NOMBRE_ARCHIVO,
        P_ARCHIVO_URL,
        P_MIME_TYPE,
        P_PESO_BYTES,
        P_FECHA_VENCIMIENTO,
        IFNULL(P_ESTADO_DOCUMENTO, 'CARGADO'),
        P_OBSERVACIONES,
        P_ID_CARGADO_POR
    );

    SET V_ID_DOCUMENTO = LAST_INSERT_ID();

    SELECT
        V_ID_DOCUMENTO AS ID_EMPLEADO_DOCUMENTO,
        P_ID_EMPLEADO AS ID_EMPLEADO,
        P_ID_TIPO_DOCUMENTO_LABORAL AS ID_TIPO_DOCUMENTO_LABORAL,
        IFNULL(P_ESTADO_DOCUMENTO, 'CARGADO') AS ESTADO_DOCUMENTO,
        P_NOMBRE_ARCHIVO AS NOMBRE_ARCHIVO,
        P_ARCHIVO_URL AS ARCHIVO_URL;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CONTRATACION_EXAMENES_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CONTRATACION_EXAMENES_LISTAR`(
    IN P_ID_EMPLEADO INT
)
BEGIN
    SELECT
        EM.ID_EXAMEN_MEDICO,
        EM.ID_EMPLEADO,
        EM.ID_TIPO_EXAMEN_MEDICO,
        TEM.NOMBRE AS TIPO_EXAMEN_MEDICO,
        EM.FECHA_EXAMEN,
        EM.ENTIDAD_REALIZA,
        EM.RESULTADO_GENERAL,
        EM.FECHA_VENCIMIENTO,
        EM.ARCHIVO_URL,
        EM.OBSERVACIONES,

        CASE
            WHEN EM.FECHA_VENCIMIENTO IS NOT NULL
             AND EM.FECHA_VENCIMIENTO < CURRENT_DATE()
            THEN 1
            ELSE 0
        END AS VENCIDO,

        CASE
            WHEN EM.FECHA_VENCIMIENTO IS NOT NULL
             AND EM.FECHA_VENCIMIENTO BETWEEN CURRENT_DATE() AND DATE_ADD(CURRENT_DATE(), INTERVAL 30 DAY)
            THEN 1
            ELSE 0
        END AS PROXIMO_VENCER,

        EM.CREATED_AT,
        EM.UPDATED_AT

    FROM bbf_empleado_examenes_medicos EM
    INNER JOIN bbf_tipos_examen_medico TEM
        ON TEM.ID_TIPO_EXAMEN_MEDICO = EM.ID_TIPO_EXAMEN_MEDICO
    WHERE EM.ID_EMPLEADO = P_ID_EMPLEADO
      AND IFNULL(EM.ELIMINADO, 0) = 0
    ORDER BY EM.FECHA_EXAMEN DESC, EM.ID_EXAMEN_MEDICO DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CONTRATACION_EXAMEN_CREAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CONTRATACION_EXAMEN_CREAR`(
    IN P_ID_EMPLEADO INT,
    IN P_ID_TIPO_EXAMEN_MEDICO INT,
    IN P_FECHA_EXAMEN DATE,
    IN P_ENTIDAD_REALIZA VARCHAR(200),
    IN P_RESULTADO_GENERAL VARCHAR(250),
    IN P_FECHA_VENCIMIENTO DATE,
    IN P_ARCHIVO_URL VARCHAR(500),
    IN P_OBSERVACIONES TEXT
)
BEGIN
    DECLARE V_EXISTE_EMPLEADO INT DEFAULT 0;
    DECLARE V_ID_EXAMEN_MEDICO INT;

    SELECT COUNT(*)
    INTO V_EXISTE_EMPLEADO
    FROM bbf_empleados
    WHERE ID_EMPLEADO = P_ID_EMPLEADO
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_EXISTE_EMPLEADO = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El empleado no existe o fue eliminado.';
    END IF;

    IF P_FECHA_VENCIMIENTO IS NOT NULL AND P_FECHA_VENCIMIENTO < P_FECHA_EXAMEN THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La fecha de vencimiento no puede ser menor a la fecha del examen.';
    END IF;

    INSERT INTO bbf_empleado_examenes_medicos (
        ID_EMPLEADO,
        ID_TIPO_EXAMEN_MEDICO,
        FECHA_EXAMEN,
        ENTIDAD_REALIZA,
        RESULTADO_GENERAL,
        FECHA_VENCIMIENTO,
        ARCHIVO_URL,
        OBSERVACIONES
    )
    VALUES (
        P_ID_EMPLEADO,
        P_ID_TIPO_EXAMEN_MEDICO,
        P_FECHA_EXAMEN,
        P_ENTIDAD_REALIZA,
        P_RESULTADO_GENERAL,
        P_FECHA_VENCIMIENTO,
        P_ARCHIVO_URL,
        P_OBSERVACIONES
    );

    SET V_ID_EXAMEN_MEDICO = LAST_INSERT_ID();

    SELECT
        V_ID_EXAMEN_MEDICO AS ID_EXAMEN_MEDICO,
        P_ID_EMPLEADO AS ID_EMPLEADO,
        P_ID_TIPO_EXAMEN_MEDICO AS ID_TIPO_EXAMEN_MEDICO,
        P_FECHA_EXAMEN AS FECHA_EXAMEN,
        P_FECHA_VENCIMIENTO AS FECHA_VENCIMIENTO;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CONTRATACION_FICHA_GUARDAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CONTRATACION_FICHA_GUARDAR`(

    IN P_ID_EMPLEADO INT,

    IN P_NUMERO_CARPETA VARCHAR(50),
    IN P_GENERO VARCHAR(20),
    IN P_FECHA_EXPEDICION_DOCUMENTO DATE,

    IN P_ID_DEPARTAMENTO_NACIMIENTO INT,
    IN P_ID_MUNICIPIO_NACIMIENTO INT,

    IN P_ID_DEPARTAMENTO_RESIDENCIA INT,
    IN P_ID_MUNICIPIO_RESIDENCIA INT,

    IN P_DIRECCION_RESIDENCIA VARCHAR(250),
    IN P_TELEFONO_ALTERNO VARCHAR(50),
    IN P_CORREO_PERSONAL VARCHAR(150),
    IN P_ESTADO_CIVIL VARCHAR(50),
    IN P_NIVEL_EDUCATIVO VARCHAR(50),
    IN P_PERSONAS_A_CARGO INT,
    IN P_NUMERO_HIJOS INT,
    IN P_PERSONAS_VIVIENDA INT,
    IN P_MENORES_ESTUDIAN TINYINT,
    IN P_OBSERVACIONES TEXT,

    IN P_CONTACTO_NOMBRE_COMPLETO VARCHAR(200),
    IN P_CONTACTO_PARENTESCO VARCHAR(100),
    IN P_CONTACTO_TELEFONO VARCHAR(50),
    IN P_CONTACTO_TELEFONO_ALTERNO VARCHAR(50),
    IN P_CONTACTO_DIRECCION VARCHAR(250),
    IN P_CONTACTO_OBSERVACIONES VARCHAR(500)
)
BEGIN

    DECLARE V_EXISTE INT DEFAULT 0;
    DECLARE V_ID_FICHA INT DEFAULT NULL;
    DECLARE V_ID_CONTACTO INT DEFAULT NULL;
    DECLARE V_ESTADO_FICHA VARCHAR(50);

    DECLARE V_DEP_NAC VARCHAR(150) DEFAULT NULL;
    DECLARE V_MUN_NAC VARCHAR(150) DEFAULT NULL;

    DECLARE V_DEP_RES VARCHAR(150) DEFAULT NULL;
    DECLARE V_MUN_RES VARCHAR(150) DEFAULT NULL;


    -- --------------------------------------------------------
    -- Empleado
    -- --------------------------------------------------------

    SELECT COUNT(*)
    INTO V_EXISTE
    FROM bbf_empleados
    WHERE ID_EMPLEADO = P_ID_EMPLEADO
      AND IFNULL(ELIMINADO, 0) = 0;


    IF V_EXISTE = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'El empleado no existe o fue eliminado.';
    END IF;


    -- --------------------------------------------------------
    -- Buscar ficha
    -- --------------------------------------------------------

    SELECT ID_FICHA_INGRESO
    INTO V_ID_FICHA
    FROM bbf_empleado_ficha_ingreso
    WHERE ID_EMPLEADO = P_ID_EMPLEADO
      AND IFNULL(ELIMINADO, 0) = 0
    LIMIT 1;


    -- Recuperar textos históricos si la ficha ya existe.
    IF V_ID_FICHA IS NOT NULL THEN

        SELECT
            DEPARTAMENTO_NACIMIENTO,
            LUGAR_NACIMIENTO,
            DEPARTAMENTO_RESIDENCIA,
            CIUDAD_RESIDENCIA
        INTO
            V_DEP_NAC,
            V_MUN_NAC,
            V_DEP_RES,
            V_MUN_RES
        FROM bbf_empleado_ficha_ingreso
        WHERE ID_FICHA_INGRESO = V_ID_FICHA
        LIMIT 1;

    END IF;


    -- --------------------------------------------------------
    -- Nacimiento
    -- --------------------------------------------------------

    IF P_ID_DEPARTAMENTO_NACIMIENTO IS NOT NULL
       OR P_ID_MUNICIPIO_NACIMIENTO IS NOT NULL THEN

        IF P_ID_DEPARTAMENTO_NACIMIENTO IS NULL
           OR P_ID_MUNICIPIO_NACIMIENTO IS NULL THEN

            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Departamento y municipio de nacimiento deben enviarse juntos.';

        END IF;


        SELECT COUNT(*)
        INTO V_EXISTE
        FROM bbf_municipios M
        INNER JOIN bbf_departamentos D
            ON D.ID_DEPARTAMENTO = M.ID_DEPARTAMENTO
        WHERE D.ID_DEPARTAMENTO =
                  P_ID_DEPARTAMENTO_NACIMIENTO
          AND M.ID_MUNICIPIO =
                  P_ID_MUNICIPIO_NACIMIENTO
          AND D.ACTIVO = 1
          AND M.ACTIVO = 1;


        IF V_EXISTE = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'El municipio de nacimiento no pertenece al departamento seleccionado.';
        END IF;


        SELECT
            D.NOMBRE,
            M.NOMBRE
        INTO
            V_DEP_NAC,
            V_MUN_NAC
        FROM bbf_municipios M
        INNER JOIN bbf_departamentos D
            ON D.ID_DEPARTAMENTO = M.ID_DEPARTAMENTO
        WHERE D.ID_DEPARTAMENTO =
                  P_ID_DEPARTAMENTO_NACIMIENTO
          AND M.ID_MUNICIPIO =
                  P_ID_MUNICIPIO_NACIMIENTO
        LIMIT 1;

    END IF;


    -- --------------------------------------------------------
    -- Residencia
    -- --------------------------------------------------------

    IF P_ID_DEPARTAMENTO_RESIDENCIA IS NOT NULL
       OR P_ID_MUNICIPIO_RESIDENCIA IS NOT NULL THEN

        IF P_ID_DEPARTAMENTO_RESIDENCIA IS NULL
           OR P_ID_MUNICIPIO_RESIDENCIA IS NULL THEN

            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Departamento y municipio de residencia deben enviarse juntos.';

        END IF;


        SELECT COUNT(*)
        INTO V_EXISTE
        FROM bbf_municipios M
        INNER JOIN bbf_departamentos D
            ON D.ID_DEPARTAMENTO = M.ID_DEPARTAMENTO
        WHERE D.ID_DEPARTAMENTO =
                  P_ID_DEPARTAMENTO_RESIDENCIA
          AND M.ID_MUNICIPIO =
                  P_ID_MUNICIPIO_RESIDENCIA
          AND D.ACTIVO = 1
          AND M.ACTIVO = 1;


        IF V_EXISTE = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'El municipio de residencia no pertenece al departamento seleccionado.';
        END IF;


        SELECT
            D.NOMBRE,
            M.NOMBRE
        INTO
            V_DEP_RES,
            V_MUN_RES
        FROM bbf_municipios M
        INNER JOIN bbf_departamentos D
            ON D.ID_DEPARTAMENTO = M.ID_DEPARTAMENTO
        WHERE D.ID_DEPARTAMENTO =
                  P_ID_DEPARTAMENTO_RESIDENCIA
          AND M.ID_MUNICIPIO =
                  P_ID_MUNICIPIO_RESIDENCIA
        LIMIT 1;

    END IF;


    -- --------------------------------------------------------
    -- Estado ficha
    -- --------------------------------------------------------

    SET V_ESTADO_FICHA =
        CASE
            WHEN P_ID_DEPARTAMENTO_RESIDENCIA IS NOT NULL
             AND P_ID_MUNICIPIO_RESIDENCIA IS NOT NULL
             AND P_DIRECCION_RESIDENCIA IS NOT NULL
             AND P_CORREO_PERSONAL IS NOT NULL
             AND P_CONTACTO_NOMBRE_COMPLETO IS NOT NULL
             AND P_CONTACTO_TELEFONO IS NOT NULL
            THEN 'COMPLETA'
            ELSE 'INCOMPLETA'
        END;


    -- --------------------------------------------------------
    -- INSERT / UPDATE ficha
    -- --------------------------------------------------------

    IF V_ID_FICHA IS NULL THEN

        INSERT INTO bbf_empleado_ficha_ingreso (
            ID_EMPLEADO,

            NUMERO_CARPETA,
            GENERO,
            FECHA_EXPEDICION_DOCUMENTO,

            ID_DEPARTAMENTO_NACIMIENTO,
            ID_MUNICIPIO_NACIMIENTO,

            LUGAR_NACIMIENTO,
            DEPARTAMENTO_NACIMIENTO,

            ID_DEPARTAMENTO_RESIDENCIA,
            ID_MUNICIPIO_RESIDENCIA,

            CIUDAD_RESIDENCIA,
            DEPARTAMENTO_RESIDENCIA,

            DIRECCION_RESIDENCIA,
            TELEFONO_ALTERNO,
            CORREO_PERSONAL,

            ESTADO_CIVIL,
            NIVEL_EDUCATIVO,

            PERSONAS_A_CARGO,
            NUMERO_HIJOS,

            PERSONAS_VIVIENDA,
            MENORES_ESTUDIAN,

            ESTADO_FICHA,
            OBSERVACIONES
        )
        VALUES (
            P_ID_EMPLEADO,

            P_NUMERO_CARPETA,
            P_GENERO,
            P_FECHA_EXPEDICION_DOCUMENTO,

            P_ID_DEPARTAMENTO_NACIMIENTO,
            P_ID_MUNICIPIO_NACIMIENTO,

            V_MUN_NAC,
            V_DEP_NAC,

            P_ID_DEPARTAMENTO_RESIDENCIA,
            P_ID_MUNICIPIO_RESIDENCIA,

            V_MUN_RES,
            V_DEP_RES,

            P_DIRECCION_RESIDENCIA,
            P_TELEFONO_ALTERNO,
            P_CORREO_PERSONAL,

            P_ESTADO_CIVIL,
            P_NIVEL_EDUCATIVO,

            IFNULL(P_PERSONAS_A_CARGO, 0),
            IFNULL(P_NUMERO_HIJOS, 0),

            P_PERSONAS_VIVIENDA,
            P_MENORES_ESTUDIAN,

            V_ESTADO_FICHA,
            P_OBSERVACIONES
        );


        SET V_ID_FICHA = LAST_INSERT_ID();

    ELSE

        UPDATE bbf_empleado_ficha_ingreso
        SET
            NUMERO_CARPETA =
                P_NUMERO_CARPETA,

            GENERO =
                P_GENERO,

            FECHA_EXPEDICION_DOCUMENTO =
                P_FECHA_EXPEDICION_DOCUMENTO,

            ID_DEPARTAMENTO_NACIMIENTO =
                P_ID_DEPARTAMENTO_NACIMIENTO,

            ID_MUNICIPIO_NACIMIENTO =
                P_ID_MUNICIPIO_NACIMIENTO,

            LUGAR_NACIMIENTO =
                V_MUN_NAC,

            DEPARTAMENTO_NACIMIENTO =
                V_DEP_NAC,

            ID_DEPARTAMENTO_RESIDENCIA =
                P_ID_DEPARTAMENTO_RESIDENCIA,

            ID_MUNICIPIO_RESIDENCIA =
                P_ID_MUNICIPIO_RESIDENCIA,

            CIUDAD_RESIDENCIA =
                V_MUN_RES,

            DEPARTAMENTO_RESIDENCIA =
                V_DEP_RES,

            DIRECCION_RESIDENCIA =
                P_DIRECCION_RESIDENCIA,

            TELEFONO_ALTERNO =
                P_TELEFONO_ALTERNO,

            CORREO_PERSONAL =
                P_CORREO_PERSONAL,

            ESTADO_CIVIL =
                P_ESTADO_CIVIL,

            NIVEL_EDUCATIVO =
                P_NIVEL_EDUCATIVO,

            PERSONAS_A_CARGO =
                IFNULL(P_PERSONAS_A_CARGO, 0),

            NUMERO_HIJOS =
                IFNULL(P_NUMERO_HIJOS, 0),

            PERSONAS_VIVIENDA =
                P_PERSONAS_VIVIENDA,

            MENORES_ESTUDIAN =
                P_MENORES_ESTUDIAN,

            ESTADO_FICHA =
                V_ESTADO_FICHA,

            OBSERVACIONES =
                P_OBSERVACIONES,

            UPDATED_AT =
                CURRENT_TIMESTAMP

        WHERE ID_FICHA_INGRESO =
              V_ID_FICHA;

    END IF;


    -- --------------------------------------------------------
    -- Contacto emergencia
    -- --------------------------------------------------------

    SELECT ID_CONTACTO_EMERGENCIA
    INTO V_ID_CONTACTO
    FROM bbf_empleado_contacto_emergencia
    WHERE ID_EMPLEADO = P_ID_EMPLEADO
      AND IFNULL(ELIMINADO, 0) = 0
    ORDER BY ID_CONTACTO_EMERGENCIA DESC
    LIMIT 1;


    IF P_CONTACTO_NOMBRE_COMPLETO IS NOT NULL
       OR P_CONTACTO_TELEFONO IS NOT NULL THEN

        IF V_ID_CONTACTO IS NULL THEN

            INSERT INTO bbf_empleado_contacto_emergencia (
                ID_EMPLEADO,
                NOMBRE_COMPLETO,
                PARENTESCO,
                TELEFONO,
                TELEFONO_ALTERNO,
                DIRECCION,
                OBSERVACIONES
            )
            VALUES (
                P_ID_EMPLEADO,
                P_CONTACTO_NOMBRE_COMPLETO,
                P_CONTACTO_PARENTESCO,
                P_CONTACTO_TELEFONO,
                P_CONTACTO_TELEFONO_ALTERNO,
                P_CONTACTO_DIRECCION,
                P_CONTACTO_OBSERVACIONES
            );

            SET V_ID_CONTACTO =
                LAST_INSERT_ID();

        ELSE

            UPDATE bbf_empleado_contacto_emergencia
            SET
                NOMBRE_COMPLETO =
                    P_CONTACTO_NOMBRE_COMPLETO,

                PARENTESCO =
                    P_CONTACTO_PARENTESCO,

                TELEFONO =
                    P_CONTACTO_TELEFONO,

                TELEFONO_ALTERNO =
                    P_CONTACTO_TELEFONO_ALTERNO,

                DIRECCION =
                    P_CONTACTO_DIRECCION,

                OBSERVACIONES =
                    P_CONTACTO_OBSERVACIONES,

                UPDATED_AT =
                    CURRENT_TIMESTAMP

            WHERE ID_CONTACTO_EMERGENCIA =
                  V_ID_CONTACTO;

        END IF;

    END IF;


    SELECT
        V_ID_FICHA AS ID_FICHA_INGRESO,
        P_ID_EMPLEADO AS ID_EMPLEADO,
        V_ESTADO_FICHA AS ESTADO_FICHA,
        V_ID_CONTACTO AS ID_CONTACTO_EMERGENCIA;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CONTRATACION_FICHA_OBTENER` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CONTRATACION_FICHA_OBTENER`(
    IN P_ID_EMPLEADO INT
)
BEGIN

    SELECT
        E.ID_EMPLEADO,
        E.ID_ASPIRANTE_ORIGEN,

        E.ID_TIPO_DOCUMENTO,
        TD.NOMBRE AS TIPO_DOCUMENTO,

        E.NUMERO_DOCUMENTO,
        E.NOMBRES,
        E.APELLIDOS,

        CONCAT(
            E.NOMBRES,
            ' ',
            E.APELLIDOS
        ) AS NOMBRE_COMPLETO,

        E.CORREO,
        E.TELEFONO,
        E.FECHA_INGRESO,
        E.FECHA_RETIRO,
        E.ESTADO_EMPLEADO,

        E.ID_AREA,
        A.NOMBRE AS AREA,

        E.ID_CARGO,
        C.NOMBRE AS CARGO,

        E.ID_TIPO_CONTRATO,
        TC.NOMBRE AS TIPO_CONTRATO,

        FI.ID_FICHA_INGRESO,

        FI.NUMERO_CARPETA,
        FI.GENERO,
        FI.FECHA_EXPEDICION_DOCUMENTO,

        FI.FECHA_NACIMIENTO,

        FI.ID_DEPARTAMENTO_NACIMIENTO,

        DN.CODIGO_DANE
            AS CODIGO_DEPARTAMENTO_NACIMIENTO,

        COALESCE(
            DN.NOMBRE,
            FI.DEPARTAMENTO_NACIMIENTO
        ) AS DEPARTAMENTO_NACIMIENTO,

        FI.ID_MUNICIPIO_NACIMIENTO,

        MN.CODIGO_DANE
            AS CODIGO_MUNICIPIO_NACIMIENTO,

        COALESCE(
            MN.NOMBRE,
            FI.LUGAR_NACIMIENTO
        ) AS LUGAR_NACIMIENTO,

        FI.NACIONALIDAD,

        FI.ID_DEPARTAMENTO_RESIDENCIA,

        DR.CODIGO_DANE
            AS CODIGO_DEPARTAMENTO_RESIDENCIA,

        COALESCE(
            DR.NOMBRE,
            FI.DEPARTAMENTO_RESIDENCIA
        ) AS DEPARTAMENTO_RESIDENCIA,

        FI.ID_MUNICIPIO_RESIDENCIA,

        MR.CODIGO_DANE
            AS CODIGO_MUNICIPIO_RESIDENCIA,

        COALESCE(
            MR.NOMBRE,
            FI.CIUDAD_RESIDENCIA
        ) AS CIUDAD_RESIDENCIA,

        FI.DIRECCION_RESIDENCIA,
        FI.TELEFONO_ALTERNO,
        FI.CORREO_PERSONAL,

        FI.ESTADO_CIVIL,
        FI.NIVEL_EDUCATIVO,

        FI.PERSONAS_A_CARGO,
        FI.NUMERO_HIJOS,
        FI.PERSONAS_VIVIENDA,
        FI.MENORES_ESTUDIAN,

        IFNULL(
            FI.ESTADO_FICHA,
            'PENDIENTE'
        ) AS ESTADO_FICHA,

        FI.OBSERVACIONES,

        CE.ID_CONTACTO_EMERGENCIA,

        CE.NOMBRE_COMPLETO
            AS CONTACTO_NOMBRE_COMPLETO,

        CE.PARENTESCO
            AS CONTACTO_PARENTESCO,

        CE.TELEFONO
            AS CONTACTO_TELEFONO,

        CE.TELEFONO_ALTERNO
            AS CONTACTO_TELEFONO_ALTERNO,

        CE.DIRECCION
            AS CONTACTO_DIRECCION,

        CE.OBSERVACIONES
            AS CONTACTO_OBSERVACIONES

    FROM bbf_empleados E

    LEFT JOIN bbf_tipos_documento TD
        ON TD.ID_TIPO_DOCUMENTO =
           E.ID_TIPO_DOCUMENTO

    LEFT JOIN bbf_areas A
        ON A.ID_AREA =
           E.ID_AREA

    LEFT JOIN bbf_cargos C
        ON C.ID_CARGO =
           E.ID_CARGO

    LEFT JOIN bbf_tipos_contrato TC
        ON TC.ID_TIPO_CONTRATO =
           E.ID_TIPO_CONTRATO

    LEFT JOIN bbf_empleado_ficha_ingreso FI
        ON FI.ID_EMPLEADO =
           E.ID_EMPLEADO
       AND IFNULL(FI.ELIMINADO, 0) = 0

    LEFT JOIN bbf_departamentos DN
        ON DN.ID_DEPARTAMENTO =
           FI.ID_DEPARTAMENTO_NACIMIENTO

    LEFT JOIN bbf_municipios MN
        ON MN.ID_MUNICIPIO =
           FI.ID_MUNICIPIO_NACIMIENTO

    LEFT JOIN bbf_departamentos DR
        ON DR.ID_DEPARTAMENTO =
           FI.ID_DEPARTAMENTO_RESIDENCIA

    LEFT JOIN bbf_municipios MR
        ON MR.ID_MUNICIPIO =
           FI.ID_MUNICIPIO_RESIDENCIA

    LEFT JOIN bbf_empleado_contacto_emergencia CE
        ON CE.ID_EMPLEADO =
           E.ID_EMPLEADO
       AND IFNULL(CE.ELIMINADO, 0) = 0

    WHERE E.ID_EMPLEADO =
          P_ID_EMPLEADO

      AND IFNULL(E.ELIMINADO, 0) = 0

    LIMIT 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CONTRATACION_LISTAR_EMPLEADOS` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CONTRATACION_LISTAR_EMPLEADOS`(
    IN P_TEXTO_BUSQUEDA VARCHAR(150),
    IN P_ID_AREA INT,
    IN P_ID_CARGO INT,
    IN P_ESTADO_EMPLEADO VARCHAR(50)
)
BEGIN
    SELECT
        E.ID_EMPLEADO,
        E.NUMERO_DOCUMENTO,
        E.NOMBRES,
        E.APELLIDOS,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS) AS NOMBRE_COMPLETO,
        E.CORREO,
        E.TELEFONO,

        E.ID_AREA,
        A.NOMBRE AS AREA,

        E.ID_CARGO,
        C.NOMBRE AS CARGO,

        E.ID_TIPO_CONTRATO,
        TC.NOMBRE AS TIPO_CONTRATO,

        E.FECHA_INGRESO,
        E.FECHA_RETIRO,
        E.ESTADO_EMPLEADO,

        FI.ID_FICHA_INGRESO,
        IFNULL(FI.ESTADO_FICHA, 'PENDIENTE') AS ESTADO_FICHA,

        EC.ID_EMPLEADO_CONTRATO AS ID_ULTIMO_CONTRATO,
        EC.FECHA_INICIO AS FECHA_INICIO_CONTRATO,
        EC.FECHA_FIN AS FECHA_FIN_CONTRATO,
        EC.ESTADO_CONTRATO,

        EC.AUXILIO_TRANSPORTE,
        EC.PERIODO_PAGO,
        EC.LUGAR_LABORES,
        EC.NUMERO_CONTRATO,
        EC.TIPO_CARGO_CONTRATO,
        EC.PRORROGA_DIAS,

        CASE
            WHEN FI.ID_FICHA_INGRESO IS NULL THEN 1
            ELSE 0
        END AS FICHA_PENDIENTE,

        CASE
            WHEN EC.FECHA_FIN IS NOT NULL
             AND EC.FECHA_FIN BETWEEN CURRENT_DATE() AND DATE_ADD(CURRENT_DATE(), INTERVAL 30 DAY)
            THEN 1
            ELSE 0
        END AS CONTRATO_PROXIMO_VENCER,

        CASE
            WHEN EC.FECHA_FIN IS NOT NULL
             AND EC.FECHA_FIN < CURRENT_DATE()
             AND EC.ESTADO_CONTRATO = 'ACTIVO'
            THEN 1
            ELSE 0
        END AS CONTRATO_VENCIDO

    FROM bbf_empleados E
    LEFT JOIN bbf_areas A
        ON A.ID_AREA = E.ID_AREA
    LEFT JOIN bbf_cargos C
        ON C.ID_CARGO = E.ID_CARGO
    LEFT JOIN bbf_tipos_contrato TC
        ON TC.ID_TIPO_CONTRATO = E.ID_TIPO_CONTRATO

    LEFT JOIN bbf_empleado_ficha_ingreso FI
        ON FI.ID_EMPLEADO = E.ID_EMPLEADO
       AND IFNULL(FI.ELIMINADO, 0) = 0

    LEFT JOIN bbf_empleado_contratos EC
        ON EC.ID_EMPLEADO_CONTRATO = (
            SELECT EC2.ID_EMPLEADO_CONTRATO
            FROM bbf_empleado_contratos EC2
            WHERE EC2.ID_EMPLEADO = E.ID_EMPLEADO
              AND IFNULL(EC2.ELIMINADO, 0) = 0
            ORDER BY EC2.FECHA_INICIO DESC, EC2.ID_EMPLEADO_CONTRATO DESC
            LIMIT 1
        )

    WHERE
        IFNULL(E.ELIMINADO, 0) = 0
        AND (P_ID_AREA IS NULL OR P_ID_AREA = 0 OR E.ID_AREA = P_ID_AREA)
        AND (P_ID_CARGO IS NULL OR P_ID_CARGO = 0 OR E.ID_CARGO = P_ID_CARGO)
        AND (P_ESTADO_EMPLEADO IS NULL OR P_ESTADO_EMPLEADO = '' OR E.ESTADO_EMPLEADO = P_ESTADO_EMPLEADO)
        AND (
            P_TEXTO_BUSQUEDA IS NULL
            OR P_TEXTO_BUSQUEDA = ''
            OR E.NUMERO_DOCUMENTO LIKE CONCAT('%', P_TEXTO_BUSQUEDA, '%')
            OR E.NOMBRES LIKE CONCAT('%', P_TEXTO_BUSQUEDA, '%')
            OR E.APELLIDOS LIKE CONCAT('%', P_TEXTO_BUSQUEDA, '%')
            OR E.CORREO LIKE CONCAT('%', P_TEXTO_BUSQUEDA, '%')
        )
    ORDER BY E.NOMBRES ASC, E.APELLIDOS ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CONTRATACION_SEGURIDAD_SOCIAL_GUARDAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CONTRATACION_SEGURIDAD_SOCIAL_GUARDAR`(
    IN P_ID_EMPLEADO INT,
    IN P_ID_EPS INT,
    IN P_ID_ARL INT,
    IN P_ID_FONDO_PENSION INT,
    IN P_ID_FONDO_CESANTIAS INT,
    IN P_ID_CAJA_COMPENSACION INT,
    IN P_FECHA_AFILIACION_EPS DATE,
    IN P_FECHA_AFILIACION_ARL DATE,
    IN P_FECHA_AFILIACION_PENSION DATE,
    IN P_FECHA_AFILIACION_CESANTIAS DATE,
    IN P_FECHA_AFILIACION_CAJA DATE,
    IN P_OBSERVACIONES TEXT
)
BEGIN
    DECLARE V_ID_SEGURIDAD_SOCIAL INT DEFAULT NULL;
    DECLARE V_EXISTE_EMPLEADO INT DEFAULT 0;

    SELECT COUNT(*)
    INTO V_EXISTE_EMPLEADO
    FROM bbf_empleados
    WHERE ID_EMPLEADO = P_ID_EMPLEADO
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_EXISTE_EMPLEADO = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El empleado no existe o fue eliminado.';
    END IF;

    SELECT ID_SEGURIDAD_SOCIAL
    INTO V_ID_SEGURIDAD_SOCIAL
    FROM bbf_empleado_seguridad_social
    WHERE ID_EMPLEADO = P_ID_EMPLEADO
      AND IFNULL(ELIMINADO, 0) = 0
    LIMIT 1;

    IF V_ID_SEGURIDAD_SOCIAL IS NULL THEN
        INSERT INTO bbf_empleado_seguridad_social (
            ID_EMPLEADO,
            ID_EPS,
            ID_ARL,
            ID_FONDO_PENSION,
            ID_FONDO_CESANTIAS,
            ID_CAJA_COMPENSACION,
            FECHA_AFILIACION_EPS,
            FECHA_AFILIACION_ARL,
            FECHA_AFILIACION_PENSION,
            FECHA_AFILIACION_CESANTIAS,
            FECHA_AFILIACION_CAJA,
            OBSERVACIONES
        )
        VALUES (
            P_ID_EMPLEADO,
            P_ID_EPS,
            P_ID_ARL,
            P_ID_FONDO_PENSION,
            P_ID_FONDO_CESANTIAS,
            P_ID_CAJA_COMPENSACION,
            P_FECHA_AFILIACION_EPS,
            P_FECHA_AFILIACION_ARL,
            P_FECHA_AFILIACION_PENSION,
            P_FECHA_AFILIACION_CESANTIAS,
            P_FECHA_AFILIACION_CAJA,
            P_OBSERVACIONES
        );

        SET V_ID_SEGURIDAD_SOCIAL = LAST_INSERT_ID();
    ELSE
        UPDATE bbf_empleado_seguridad_social
        SET
            ID_EPS = P_ID_EPS,
            ID_ARL = P_ID_ARL,
            ID_FONDO_PENSION = P_ID_FONDO_PENSION,
            ID_FONDO_CESANTIAS = P_ID_FONDO_CESANTIAS,
            ID_CAJA_COMPENSACION = P_ID_CAJA_COMPENSACION,
            FECHA_AFILIACION_EPS = P_FECHA_AFILIACION_EPS,
            FECHA_AFILIACION_ARL = P_FECHA_AFILIACION_ARL,
            FECHA_AFILIACION_PENSION = P_FECHA_AFILIACION_PENSION,
            FECHA_AFILIACION_CESANTIAS = P_FECHA_AFILIACION_CESANTIAS,
            FECHA_AFILIACION_CAJA = P_FECHA_AFILIACION_CAJA,
            OBSERVACIONES = P_OBSERVACIONES,
            UPDATED_AT = CURRENT_TIMESTAMP
        WHERE ID_SEGURIDAD_SOCIAL = V_ID_SEGURIDAD_SOCIAL;
    END IF;

    SELECT
        V_ID_SEGURIDAD_SOCIAL AS ID_SEGURIDAD_SOCIAL,
        P_ID_EMPLEADO AS ID_EMPLEADO;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CONTRATACION_SEGURIDAD_SOCIAL_OBTENER` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CONTRATACION_SEGURIDAD_SOCIAL_OBTENER`(
    IN P_ID_EMPLEADO INT
)
BEGIN
    SELECT
        SS.ID_SEGURIDAD_SOCIAL,
        SS.ID_EMPLEADO,

        SS.ID_EPS,
        EPS.NOMBRE AS EPS,

        SS.ID_ARL,
        ARL.NOMBRE AS ARL,

        SS.ID_FONDO_PENSION,
        PEN.NOMBRE AS FONDO_PENSION,

        SS.ID_FONDO_CESANTIAS,
        CES.NOMBRE AS FONDO_CESANTIAS,

        SS.ID_CAJA_COMPENSACION,
        CAJA.NOMBRE AS CAJA_COMPENSACION,

        SS.FECHA_AFILIACION_EPS,
        SS.FECHA_AFILIACION_ARL,
        SS.FECHA_AFILIACION_PENSION,
        SS.FECHA_AFILIACION_CESANTIAS,
        SS.FECHA_AFILIACION_CAJA,

        SS.OBSERVACIONES,
        SS.CREATED_AT,
        SS.UPDATED_AT

    FROM bbf_empleado_seguridad_social SS
    LEFT JOIN bbf_entidades_seguridad_social EPS
        ON EPS.ID_ENTIDAD_SEGURIDAD_SOCIAL = SS.ID_EPS
    LEFT JOIN bbf_entidades_seguridad_social ARL
        ON ARL.ID_ENTIDAD_SEGURIDAD_SOCIAL = SS.ID_ARL
    LEFT JOIN bbf_entidades_seguridad_social PEN
        ON PEN.ID_ENTIDAD_SEGURIDAD_SOCIAL = SS.ID_FONDO_PENSION
    LEFT JOIN bbf_entidades_seguridad_social CES
        ON CES.ID_ENTIDAD_SEGURIDAD_SOCIAL = SS.ID_FONDO_CESANTIAS
    LEFT JOIN bbf_entidades_seguridad_social CAJA
        ON CAJA.ID_ENTIDAD_SEGURIDAD_SOCIAL = SS.ID_CAJA_COMPENSACION
    WHERE SS.ID_EMPLEADO = P_ID_EMPLEADO
      AND IFNULL(SS.ELIMINADO, 0) = 0
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CONTRATO_PLANTILLAS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CONTRATO_PLANTILLAS_LISTAR`(
    IN P_ID_TIPO_CONTRATO INT,
    IN P_TIPO_CARGO_CONTRATO VARCHAR(30),
    IN P_SOLO_ACTIVAS TINYINT
)
BEGIN
    SELECT
        P.ID_PLANTILLA_CONTRATO,
        P.ID_TIPO_CONTRATO,
        TC.NOMBRE AS TIPO_CONTRATO,
        P.NOMBRE_PLANTILLA,
        P.CODIGO_FORMATO,
        P.VERSION_FORMATO,
        P.FECHA_VIGENCIA,
        P.TIPO_CARGO_CONTRATO,
        P.DESCRIPCION,
        P.ARCHIVO_PLANTILLA_URL,
        P.ARCHIVO_PLANTILLA_RUTA,
        P.FORMATO_SALIDA_DEFAULT,
        P.CONFIG_CAMPOS_JSON,
        P.VALORES_DEFAULT_JSON,
        P.ACTIVO,
        P.CREATED_AT,
        P.UPDATED_AT
    FROM bbf_contrato_plantillas P
    INNER JOIN bbf_tipos_contrato TC
        ON TC.ID_TIPO_CONTRATO = P.ID_TIPO_CONTRATO
    WHERE IFNULL(P.ELIMINADO, 0) = 0
      AND (P_ID_TIPO_CONTRATO IS NULL OR P.ID_TIPO_CONTRATO = P_ID_TIPO_CONTRATO)
      AND (P_TIPO_CARGO_CONTRATO IS NULL OR P.TIPO_CARGO_CONTRATO = P_TIPO_CARGO_CONTRATO)
      AND (IFNULL(P_SOLO_ACTIVAS, 1) = 0 OR P.ACTIVO = 1)
    ORDER BY TC.NOMBRE, P.TIPO_CARGO_CONTRATO, P.NOMBRE_PLANTILLA;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CONTRATO_PLANTILLA_OBTENER` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CONTRATO_PLANTILLA_OBTENER`(
    IN P_ID_PLANTILLA_CONTRATO INT
)
BEGIN
    SELECT
        P.ID_PLANTILLA_CONTRATO,
        P.ID_TIPO_CONTRATO,
        TC.NOMBRE AS TIPO_CONTRATO,
        P.NOMBRE_PLANTILLA,
        P.CODIGO_FORMATO,
        P.VERSION_FORMATO,
        P.FECHA_VIGENCIA,
        P.TIPO_CARGO_CONTRATO,
        P.DESCRIPCION,
        P.ARCHIVO_PLANTILLA_URL,
        P.ARCHIVO_PLANTILLA_RUTA,
        P.FORMATO_SALIDA_DEFAULT,
        P.CONFIG_CAMPOS_JSON,
        P.VALORES_DEFAULT_JSON,
        P.ACTIVO,
        P.CREATED_AT,
        P.UPDATED_AT
    FROM bbf_contrato_plantillas P
    INNER JOIN bbf_tipos_contrato TC
        ON TC.ID_TIPO_CONTRATO = P.ID_TIPO_CONTRATO
    WHERE P.ID_PLANTILLA_CONTRATO = P_ID_PLANTILLA_CONTRATO
      AND IFNULL(P.ELIMINADO, 0) = 0
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_CONTRATO_PLANTILLA_POR_TIPO_OBTENER` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_CONTRATO_PLANTILLA_POR_TIPO_OBTENER`(
    IN P_ID_TIPO_CONTRATO INT,
    IN P_TIPO_CARGO_CONTRATO VARCHAR(30)
)
BEGIN
    SELECT
        P.ID_PLANTILLA_CONTRATO,
        P.ID_TIPO_CONTRATO,
        TC.NOMBRE AS TIPO_CONTRATO,
        P.NOMBRE_PLANTILLA,
        P.CODIGO_FORMATO,
        P.VERSION_FORMATO,
        P.FECHA_VIGENCIA,
        P.TIPO_CARGO_CONTRATO,
        P.DESCRIPCION,
        P.ARCHIVO_PLANTILLA_URL,
        P.ARCHIVO_PLANTILLA_RUTA,
        P.FORMATO_SALIDA_DEFAULT,
        P.CONFIG_CAMPOS_JSON,
        P.VALORES_DEFAULT_JSON,
        P.ACTIVO
    FROM bbf_contrato_plantillas P
    INNER JOIN bbf_tipos_contrato TC
        ON TC.ID_TIPO_CONTRATO = P.ID_TIPO_CONTRATO
    WHERE P.ID_TIPO_CONTRATO = P_ID_TIPO_CONTRATO
      AND IFNULL(P.ELIMINADO, 0) = 0
      AND P.ACTIVO = 1
      AND (
            P_TIPO_CARGO_CONTRATO IS NULL
            OR P.TIPO_CARGO_CONTRATO = P_TIPO_CARGO_CONTRATO
            OR P.TIPO_CARGO_CONTRATO IS NULL
      )
    ORDER BY
        CASE
            WHEN P.TIPO_CARGO_CONTRATO = P_TIPO_CARGO_CONTRATO THEN 1
            WHEN P.TIPO_CARGO_CONTRATO IS NULL THEN 2
            ELSE 3
        END,
        P.ID_PLANTILLA_CONTRATO
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DEPARTAMENTOS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DEPARTAMENTOS_LISTAR`()
BEGIN
    SELECT
        ID_DEPARTAMENTO,
        CODIGO_DANE,
        NOMBRE
    FROM bbf_departamentos
    WHERE ACTIVO = 1
    ORDER BY NOMBRE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DEVOLUCIONES_ENTREGAS_DISPONIBLES_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DEVOLUCIONES_ENTREGAS_DISPONIBLES_LISTAR`(
        IN P_TIPO_DEVOLUCION VARCHAR(20),
        IN P_ID_EMPLEADO INT
    )
BEGIN
    IF UPPER(
        TRIM(P_TIPO_DEVOLUCION)
    ) NOT IN (
        'DOTACION',
        'HERRAMIENTA'
    ) THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'El tipo debe ser DOTACION o HERRAMIENTA.';
    END IF;

    IF P_ID_EMPLEADO IS NULL
       OR P_ID_EMPLEADO <= 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'El empleado es obligatorio.';
    END IF;

    IF UPPER(
        TRIM(P_TIPO_DEVOLUCION)
    ) = 'DOTACION' THEN

        SELECT
            'DOTACION'
                AS TIPO_DEVOLUCION,

            DE.ID_DOTACION_ENTREGA
                AS ID_ENTREGA,

            DD.ID_DOTACION_ENTREGA_DETALLE
                AS ID_DETALLE,

            DE.ID_EMPLEADO,
            DE.FECHA_ENTREGA,

            DD.ID_DOTACION_ARTICULO,
            DA.CODIGO AS CODIGO_ARTICULO,

            COALESCE(
                DA.NOMBRE,
                TD.NOMBRE
            ) AS ELEMENTO,

            TD.NOMBRE AS TIPO_DOTACION,

            T.TALLA,

            DD.CANTIDAD
                AS CANTIDAD_ENTREGADA,

            COALESCE(
                DV.CANTIDAD_RESERVADA,
                0
            ) AS CANTIDAD_DEVUELTA,

            DD.CANTIDAD
            -
            COALESCE(
                DV.CANTIDAD_RESERVADA,
                0
            ) AS CANTIDAD_DISPONIBLE

        FROM bbf_dotacion_entregas DE

        INNER JOIN bbf_dotacion_entrega_detalle DD
            ON DD.ID_DOTACION_ENTREGA =
               DE.ID_DOTACION_ENTREGA

           AND IFNULL(
               DD.ELIMINADO,
               0
           ) = 0

        INNER JOIN bbf_tipos_dotacion TD
            ON TD.ID_TIPO_DOTACION =
               DD.ID_TIPO_DOTACION

        LEFT JOIN bbf_dotacion_articulos DA
            ON DA.ID_DOTACION_ARTICULO =
               DD.ID_DOTACION_ARTICULO

        LEFT JOIN bbf_tallas_dotacion T
            ON T.ID_TALLA_DOTACION =
               DD.ID_TALLA_DOTACION

        LEFT JOIN
        (
            SELECT
                DDET.ID_DOTACION_ENTREGA_DETALLE,

                SUM(
                    DDET.CANTIDAD_DEVUELTA
                ) AS CANTIDAD_RESERVADA

            FROM bbf_devolucion_detalle DDET

            INNER JOIN bbf_devoluciones DEV
                ON DEV.ID_DEVOLUCION =
                   DDET.ID_DEVOLUCION

               AND DEV.ESTADO IN (
                   'REGISTRADA',
                   'CONFIRMADA'
               )

            GROUP BY
                DDET.ID_DOTACION_ENTREGA_DETALLE
        ) DV
            ON DV.ID_DOTACION_ENTREGA_DETALLE =
               DD.ID_DOTACION_ENTREGA_DETALLE

        WHERE DE.ID_EMPLEADO =
              P_ID_EMPLEADO

          AND DE.ESTADO = 'ENTREGADA'
          AND IFNULL(DE.ELIMINADO, 0) = 0

          AND DD.CANTIDAD >
              COALESCE(
                  DV.CANTIDAD_RESERVADA,
                  0
              )

        ORDER BY
            DE.FECHA_ENTREGA DESC,
            DE.ID_DOTACION_ENTREGA DESC,

            COALESCE(
                DA.NOMBRE,
                TD.NOMBRE
            ) ASC;

    ELSE

        SELECT
            'HERRAMIENTA'
                AS TIPO_DEVOLUCION,

            HE.id_entrega
                AS ID_ENTREGA,

            HD.id_detalle
                AS ID_DETALLE,

            HE.id_empleado
                AS ID_EMPLEADO,

            HE.fecha_entrega
                AS FECHA_ENTREGA,

            NULL
                AS ID_DOTACION_ARTICULO,

            NULL
                AS CODIGO_ARTICULO,

            H.nombre
                AS ELEMENTO,

            NULL
                AS TIPO_DOTACION,

            NULL
                AS TALLA,

            HD.cantidad
                AS CANTIDAD_ENTREGADA,

            COALESCE(
                DV.CANTIDAD_RESERVADA,
                0
            ) AS CANTIDAD_DEVUELTA,

            HD.cantidad
            -
            COALESCE(
                DV.CANTIDAD_RESERVADA,
                0
            ) AS CANTIDAD_DISPONIBLE

        FROM bbf_herramientas_entregas HE

        INNER JOIN bbf_herramientas_entrega_detalle HD
            ON HD.id_entrega =
               HE.id_entrega

        INNER JOIN bbf_herramientas H
            ON H.id_herramienta =
               HD.id_herramienta

        LEFT JOIN
        (
            SELECT
                DDET.ID_HERRAMIENTA_ENTREGA_DETALLE,

                SUM(
                    DDET.CANTIDAD_DEVUELTA
                ) AS CANTIDAD_RESERVADA

            FROM bbf_devolucion_detalle DDET

            INNER JOIN bbf_devoluciones DEV
                ON DEV.ID_DEVOLUCION =
                   DDET.ID_DEVOLUCION

               AND DEV.ESTADO IN (
                   'REGISTRADA',
                   'CONFIRMADA'
               )

            GROUP BY
                DDET.ID_HERRAMIENTA_ENTREGA_DETALLE
        ) DV
            ON DV.ID_HERRAMIENTA_ENTREGA_DETALLE =
               HD.id_detalle

        WHERE HE.id_empleado =
              P_ID_EMPLEADO

          AND HE.estado = 'confirmada'

          AND HD.cantidad >
              COALESCE(
                  DV.CANTIDAD_RESERVADA,
                  0
              )

        ORDER BY
            HE.fecha_entrega DESC,
            HE.id_entrega DESC,
            H.nombre ASC;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DEVOLUCIONES_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DEVOLUCIONES_LISTAR`(
    IN P_TIPO_DEVOLUCION VARCHAR(20),
    IN P_ID_EMPLEADO INT,
    IN P_ESTADO VARCHAR(20),
    IN P_FECHA_INICIO DATE,
    IN P_FECHA_FIN DATE
)
BEGIN
    SELECT
        DEV.ID_DEVOLUCION,
        DEV.TIPO_DEVOLUCION,
        DEV.ID_EMPLEADO,
        E.NUMERO_DOCUMENTO,
        CONCAT_WS(' ', E.NOMBRES, E.APELLIDOS) AS NOMBRE_COMPLETO,
        DEV.ID_DOTACION_ENTREGA,
        DEV.ID_HERRAMIENTA_ENTREGA,
        DEV.FECHA_DEVOLUCION,
        DEV.ESTADO,
        DEV.MOTIVO,
        DEV.OBSERVACIONES,
        DEV.ID_REGISTRADO_POR,
        DEV.ID_CONFIRMADO_POR,
        DEV.FECHA_CONFIRMACION,
        (
            SELECT COUNT(*)
            FROM bbf_devolucion_detalle DET
            WHERE DET.ID_DEVOLUCION = DEV.ID_DEVOLUCION
        ) AS TOTAL_ELEMENTOS,
        (
            SELECT COALESCE(SUM(DET.CANTIDAD_DEVUELTA), 0)
            FROM bbf_devolucion_detalle DET
            WHERE DET.ID_DEVOLUCION = DEV.ID_DEVOLUCION
        ) AS TOTAL_UNIDADES,
        (
            SELECT COUNT(*)
            FROM bbf_devolucion_evidencias EVI
            WHERE EVI.ID_DEVOLUCION = DEV.ID_DEVOLUCION
        ) AS TOTAL_EVIDENCIAS,
        DEV.CREATED_AT,
        DEV.UPDATED_AT
    FROM bbf_devoluciones DEV
    INNER JOIN bbf_empleados E
        ON E.ID_EMPLEADO = DEV.ID_EMPLEADO
    WHERE (
        P_TIPO_DEVOLUCION IS NULL
        OR TRIM(P_TIPO_DEVOLUCION) = ''
        OR UPPER(TRIM(P_TIPO_DEVOLUCION)) = DEV.TIPO_DEVOLUCION
    )
      AND (
        P_ID_EMPLEADO IS NULL
        OR P_ID_EMPLEADO = 0
        OR P_ID_EMPLEADO = DEV.ID_EMPLEADO
      )
      AND (
        P_ESTADO IS NULL
        OR TRIM(P_ESTADO) = ''
        OR UPPER(TRIM(P_ESTADO)) = DEV.ESTADO
      )
      AND (P_FECHA_INICIO IS NULL
           OR DEV.FECHA_DEVOLUCION >= P_FECHA_INICIO)
      AND (P_FECHA_FIN IS NULL
           OR DEV.FECHA_DEVOLUCION <= P_FECHA_FIN)
    ORDER BY DEV.FECHA_DEVOLUCION DESC,
             DEV.ID_DEVOLUCION DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DEVOLUCION_ANULAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DEVOLUCION_ANULAR`(
    IN P_ID_DEVOLUCION INT,
    IN P_ID_ANULADO_POR INT,
    IN P_MOTIVO_ANULACION VARCHAR(500)
)
BEGIN
    DECLARE V_ESTADO VARCHAR(20);

    IF P_MOTIVO_ANULACION IS NULL
       OR TRIM(P_MOTIVO_ANULACION) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El motivo de anulación es obligatorio.';
    END IF;

    START TRANSACTION;

    SELECT ESTADO INTO V_ESTADO
    FROM bbf_devoluciones
    WHERE ID_DEVOLUCION = P_ID_DEVOLUCION
    FOR UPDATE;

    IF V_ESTADO IS NULL THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La devolución no existe.';
    END IF;

    IF V_ESTADO = 'ANULADA' THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La devolución ya se encuentra anulada.';
    END IF;

    UPDATE bbf_devoluciones
    SET ESTADO = 'ANULADA',
        ID_ANULADO_POR = P_ID_ANULADO_POR,
        FECHA_ANULACION = CURRENT_TIMESTAMP,
        MOTIVO_ANULACION = TRIM(P_MOTIVO_ANULACION)
    WHERE ID_DEVOLUCION = P_ID_DEVOLUCION;

    COMMIT;

    SELECT
        P_ID_DEVOLUCION AS ID_DEVOLUCION,
        'ANULADA' AS ESTADO,
        'Devolución anulada correctamente.' AS MENSAJE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DEVOLUCION_CONFIRMAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DEVOLUCION_CONFIRMAR`(
    IN P_ID_DEVOLUCION INT,
    IN P_ID_CONFIRMADO_POR INT
)
BEGIN
    DECLARE V_TIPO VARCHAR(20);
    DECLARE V_ESTADO VARCHAR(20);
    DECLARE V_EVIDENCIAS INT DEFAULT 0;
    DECLARE V_FOTOS INT DEFAULT 0;

    START TRANSACTION;

    SELECT TIPO_DEVOLUCION, ESTADO
      INTO V_TIPO, V_ESTADO
    FROM bbf_devoluciones
    WHERE ID_DEVOLUCION = P_ID_DEVOLUCION
    FOR UPDATE;

    IF V_ESTADO IS NULL THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La devolución no existe.';
    END IF;

    IF V_ESTADO <> 'REGISTRADA' THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Solo se puede confirmar una devolución registrada.';
    END IF;

    SELECT
        COUNT(*),
        SUM(
            CASE
                WHEN TIPO_EVIDENCIA = 'FOTO'
                 AND MIME_TYPE LIKE 'image/%'
                THEN 1 ELSE 0
            END
        )
    INTO V_EVIDENCIAS, V_FOTOS
    FROM bbf_devolucion_evidencias
    WHERE ID_DEVOLUCION = P_ID_DEVOLUCION;

    IF V_EVIDENCIAS = 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La devolución requiere evidencia.';
    END IF;

    IF V_TIPO = 'HERRAMIENTA' AND COALESCE(V_FOTOS, 0) = 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'La devolución de herramientas requiere una fotografía.';
    END IF;

    UPDATE bbf_devoluciones
    SET ESTADO = 'CONFIRMADA',
        ID_CONFIRMADO_POR = P_ID_CONFIRMADO_POR,
        FECHA_CONFIRMACION = CURRENT_TIMESTAMP
    WHERE ID_DEVOLUCION = P_ID_DEVOLUCION;

    COMMIT;

    SELECT
        P_ID_DEVOLUCION AS ID_DEVOLUCION,
        'CONFIRMADA' AS ESTADO,
        'Devolución confirmada correctamente.' AS MENSAJE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DEVOLUCION_CREAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DEVOLUCION_CREAR`(
    IN P_TIPO_DEVOLUCION VARCHAR(20),
    IN P_ID_EMPLEADO INT,
    IN P_ID_ENTREGA INT,
    IN P_FECHA_DEVOLUCION DATE,
    IN P_MOTIVO VARCHAR(500),
    IN P_OBSERVACIONES TEXT,
    IN P_ID_REGISTRADO_POR INT,
    IN P_DETALLES LONGTEXT,
    IN P_EVIDENCIAS LONGTEXT
)
BEGIN
    DECLARE V_TIPO VARCHAR(20);
    DECLARE V_ID_DEVOLUCION INT;
    DECLARE V_EXISTE INT DEFAULT 0;
    DECLARE V_INVALIDOS INT DEFAULT 0;
    DECLARE V_TOTAL INT DEFAULT 0;
    DECLARE V_INDICE INT DEFAULT 0;
    DECLARE V_ID_DETALLE INT;
    DECLARE V_CANTIDAD INT;
    DECLARE V_ESTADO_ELEMENTO VARCHAR(30);
    DECLARE V_OBSERVACION_DETALLE VARCHAR(500);
    DECLARE V_TIPO_EVIDENCIA VARCHAR(20);
    DECLARE V_NOMBRE_ARCHIVO VARCHAR(255);
    DECLARE V_NOMBRE_ORIGINAL VARCHAR(255);
    DECLARE V_ARCHIVO_URL VARCHAR(500);
    DECLARE V_ARCHIVO_RUTA VARCHAR(500);
    DECLARE V_MIME_TYPE VARCHAR(100);
    DECLARE V_PESO_BYTES BIGINT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        DROP TEMPORARY TABLE IF EXISTS TMP_DEV_DETALLES;
        DROP TEMPORARY TABLE IF EXISTS TMP_DEV_EVIDENCIAS;
        RESIGNAL;
    END;

    SET V_TIPO = UPPER(TRIM(P_TIPO_DEVOLUCION));

    IF V_TIPO NOT IN ('DOTACION','HERRAMIENTA') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El tipo debe ser DOTACION o HERRAMIENTA.';
    END IF;

    IF P_ID_EMPLEADO IS NULL OR P_ID_EMPLEADO <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El empleado es obligatorio.';
    END IF;

    IF P_ID_ENTREGA IS NULL OR P_ID_ENTREGA <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La entrega original es obligatoria.';
    END IF;

    IF P_MOTIVO IS NULL OR TRIM(P_MOTIVO) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El motivo de la devolución es obligatorio.';
    END IF;

    IF P_ID_REGISTRADO_POR IS NULL OR P_ID_REGISTRADO_POR <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El usuario que registra es obligatorio.';
    END IF;

    IF P_DETALLES IS NULL OR TRIM(P_DETALLES) = ''
       OR JSON_VALID(P_DETALLES) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El detalle no contiene un JSON válido.';
    END IF;

    IF JSON_TYPE(P_DETALLES) <> 'ARRAY'
       OR JSON_LENGTH(P_DETALLES) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Debe registrar al menos un elemento.';
    END IF;

    IF P_EVIDENCIAS IS NULL OR TRIM(P_EVIDENCIAS) = ''
       OR JSON_VALID(P_EVIDENCIAS) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Las evidencias no contienen un JSON válido.';
    END IF;

    IF JSON_TYPE(P_EVIDENCIAS) <> 'ARRAY'
       OR JSON_LENGTH(P_EVIDENCIAS) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Debe registrar al menos una evidencia.';
    END IF;

    CREATE TEMPORARY TABLE TMP_DEV_DETALLES (
        ID_DETALLE INT NOT NULL,
        CANTIDAD INT NOT NULL,
        ESTADO_ELEMENTO VARCHAR(30) NOT NULL,
        OBSERVACIONES VARCHAR(500) NULL,
        PRIMARY KEY (ID_DETALLE)
    ) ENGINE=MEMORY;

    SET V_TOTAL = JSON_LENGTH(P_DETALLES);
    SET V_INDICE = 0;

    WHILE V_INDICE < V_TOTAL DO
        SET V_ID_DETALLE = CAST(
            JSON_UNQUOTE(
                JSON_EXTRACT(
                    P_DETALLES,
                    CONCAT('$[', V_INDICE, '].id_detalle')
                )
            ) AS SIGNED
        );

        SET V_CANTIDAD = CAST(
            JSON_UNQUOTE(
                JSON_EXTRACT(
                    P_DETALLES,
                    CONCAT('$[', V_INDICE, '].cantidad')
                )
            ) AS SIGNED
        );

        SET V_ESTADO_ELEMENTO = UPPER(TRIM(
            JSON_UNQUOTE(
                JSON_EXTRACT(
                    P_DETALLES,
                    CONCAT('$[', V_INDICE, '].estado_elemento')
                )
            )
        ));

        SET V_OBSERVACION_DETALLE = NULLIF(
            JSON_UNQUOTE(
                JSON_EXTRACT(
                    P_DETALLES,
                    CONCAT('$[', V_INDICE, '].observaciones')
                )
            ),
            'null'
        );

        IF V_ID_DETALLE IS NULL OR V_ID_DETALLE <= 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Uno de los elementos no contiene un id_detalle válido.';
        END IF;

        IF EXISTS (
            SELECT 1
            FROM TMP_DEV_DETALLES
            WHERE ID_DETALLE = V_ID_DETALLE
        ) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El detalle contiene elementos duplicados.';
        END IF;

        INSERT INTO TMP_DEV_DETALLES (
            ID_DETALLE,
            CANTIDAD,
            ESTADO_ELEMENTO,
            OBSERVACIONES
        )
        VALUES (
            V_ID_DETALLE,
            V_CANTIDAD,
            V_ESTADO_ELEMENTO,
            NULLIF(TRIM(V_OBSERVACION_DETALLE), '')
        );

        SET V_INDICE = V_INDICE + 1;
    END WHILE;

    SELECT COUNT(*) INTO V_INVALIDOS
    FROM TMP_DEV_DETALLES
    WHERE CANTIDAD <= 0
       OR ESTADO_ELEMENTO NOT IN (
           'BUENO','USADO','DETERIORADO',
           'DANADO','INCOMPLETO','NO_FUNCIONAL'
       );

    IF V_INVALIDOS > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cantidad o estado de elemento inválido.';
    END IF;

    CREATE TEMPORARY TABLE TMP_DEV_EVIDENCIAS (
        TIPO_EVIDENCIA VARCHAR(20) NOT NULL,
        NOMBRE_ARCHIVO VARCHAR(255) NOT NULL,
        NOMBRE_ORIGINAL VARCHAR(255) NULL,
        ARCHIVO_URL VARCHAR(500) NULL,
        ARCHIVO_RUTA VARCHAR(500) NULL,
        MIME_TYPE VARCHAR(100) NOT NULL,
        PESO_BYTES BIGINT NULL
    ) ENGINE=MEMORY;

    SET V_TOTAL = JSON_LENGTH(P_EVIDENCIAS);
    SET V_INDICE = 0;

    WHILE V_INDICE < V_TOTAL DO
        SET V_TIPO_EVIDENCIA = UPPER(TRIM(
            JSON_UNQUOTE(
                JSON_EXTRACT(
                    P_EVIDENCIAS,
                    CONCAT('$[', V_INDICE, '].tipo_evidencia')
                )
            )
        ));

        SET V_NOMBRE_ARCHIVO = TRIM(
            JSON_UNQUOTE(
                JSON_EXTRACT(
                    P_EVIDENCIAS,
                    CONCAT('$[', V_INDICE, '].nombre_archivo')
                )
            )
        );

        SET V_NOMBRE_ORIGINAL = NULLIF(
            JSON_UNQUOTE(
                JSON_EXTRACT(
                    P_EVIDENCIAS,
                    CONCAT('$[', V_INDICE, '].nombre_original')
                )
            ),
            'null'
        );

        SET V_ARCHIVO_URL = NULLIF(
            JSON_UNQUOTE(
                JSON_EXTRACT(
                    P_EVIDENCIAS,
                    CONCAT('$[', V_INDICE, '].archivo_url')
                )
            ),
            'null'
        );

        SET V_ARCHIVO_RUTA = NULLIF(
            JSON_UNQUOTE(
                JSON_EXTRACT(
                    P_EVIDENCIAS,
                    CONCAT('$[', V_INDICE, '].archivo_ruta')
                )
            ),
            'null'
        );

        SET V_MIME_TYPE = LOWER(TRIM(
            JSON_UNQUOTE(
                JSON_EXTRACT(
                    P_EVIDENCIAS,
                    CONCAT('$[', V_INDICE, '].mime_type')
                )
            )
        ));

        SET V_PESO_BYTES = CAST(
            JSON_UNQUOTE(
                JSON_EXTRACT(
                    P_EVIDENCIAS,
                    CONCAT('$[', V_INDICE, '].peso_bytes')
                )
            ) AS SIGNED
        );

        INSERT INTO TMP_DEV_EVIDENCIAS (
            TIPO_EVIDENCIA,
            NOMBRE_ARCHIVO,
            NOMBRE_ORIGINAL,
            ARCHIVO_URL,
            ARCHIVO_RUTA,
            MIME_TYPE,
            PESO_BYTES
        )
        VALUES (
            V_TIPO_EVIDENCIA,
            V_NOMBRE_ARCHIVO,
            NULLIF(TRIM(V_NOMBRE_ORIGINAL), ''),
            NULLIF(TRIM(V_ARCHIVO_URL), ''),
            NULLIF(TRIM(V_ARCHIVO_RUTA), ''),
            V_MIME_TYPE,
            V_PESO_BYTES
        );

        SET V_INDICE = V_INDICE + 1;
    END WHILE;

    SELECT COUNT(*) INTO V_INVALIDOS
    FROM TMP_DEV_EVIDENCIAS
    WHERE TIPO_EVIDENCIA NOT IN ('FOTO','DOCUMENTO','OTRO')
       OR NOMBRE_ARCHIVO IS NULL
       OR TRIM(NOMBRE_ARCHIVO) = ''
       OR MIME_TYPE IS NULL
       OR TRIM(MIME_TYPE) = ''
       OR (
            (ARCHIVO_URL IS NULL AND ARCHIVO_RUTA IS NULL)
            OR
            (ARCHIVO_URL IS NOT NULL AND ARCHIVO_RUTA IS NOT NULL)
       )
       OR (PESO_BYTES IS NOT NULL AND PESO_BYTES <= 0);

    IF V_INVALIDOS > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Una o más evidencias son inválidas.';
    END IF;

    IF V_TIPO = 'HERRAMIENTA'
       AND NOT EXISTS (
           SELECT 1
           FROM TMP_DEV_EVIDENCIAS
           WHERE TIPO_EVIDENCIA = 'FOTO'
             AND MIME_TYPE LIKE 'image/%'
       ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'La devolución de herramientas requiere al menos una fotografía.';
    END IF;

    START TRANSACTION;

    SET V_EXISTE = 0;

    IF V_TIPO = 'DOTACION' THEN
        SELECT ID_DOTACION_ENTREGA INTO V_EXISTE
        FROM bbf_dotacion_entregas
        WHERE ID_DOTACION_ENTREGA = P_ID_ENTREGA
          AND ID_EMPLEADO = P_ID_EMPLEADO
          AND ESTADO = 'ENTREGADA'
          AND IFNULL(ELIMINADO, 0) = 0
        FOR UPDATE;
    ELSE
        SELECT id_entrega INTO V_EXISTE
        FROM bbf_herramientas_entregas
        WHERE id_entrega = P_ID_ENTREGA
          AND id_empleado = P_ID_EMPLEADO
          AND estado = 'confirmada'
        FOR UPDATE;
    END IF;

    IF V_EXISTE = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'La entrega no existe, no pertenece al empleado o no está confirmada.';
    END IF;

    IF V_TIPO = 'DOTACION' THEN
        SELECT COUNT(*) INTO V_INVALIDOS
        FROM TMP_DEV_DETALLES TMP
        LEFT JOIN bbf_dotacion_entrega_detalle ORIG
            ON ORIG.ID_DOTACION_ENTREGA_DETALLE = TMP.ID_DETALLE
           AND ORIG.ID_DOTACION_ENTREGA = P_ID_ENTREGA
           AND IFNULL(ORIG.ELIMINADO, 0) = 0
        LEFT JOIN (
            SELECT
                DET.ID_DOTACION_ENTREGA_DETALLE,
                SUM(DET.CANTIDAD_DEVUELTA) AS RESERVADA
            FROM bbf_devolucion_detalle DET
            INNER JOIN bbf_devoluciones DEV
                ON DEV.ID_DEVOLUCION = DET.ID_DEVOLUCION
               AND DEV.ESTADO IN ('REGISTRADA','CONFIRMADA')
            GROUP BY DET.ID_DOTACION_ENTREGA_DETALLE
        ) ACUM
            ON ACUM.ID_DOTACION_ENTREGA_DETALLE = TMP.ID_DETALLE
        WHERE ORIG.ID_DOTACION_ENTREGA_DETALLE IS NULL
           OR TMP.CANTIDAD >
              ORIG.CANTIDAD - COALESCE(ACUM.RESERVADA, 0);
    ELSE
        SELECT COUNT(*) INTO V_INVALIDOS
        FROM TMP_DEV_DETALLES TMP
        LEFT JOIN bbf_herramientas_entrega_detalle ORIG
            ON ORIG.id_detalle = TMP.ID_DETALLE
           AND ORIG.id_entrega = P_ID_ENTREGA
        LEFT JOIN (
            SELECT
                DET.ID_HERRAMIENTA_ENTREGA_DETALLE,
                SUM(DET.CANTIDAD_DEVUELTA) AS RESERVADA
            FROM bbf_devolucion_detalle DET
            INNER JOIN bbf_devoluciones DEV
                ON DEV.ID_DEVOLUCION = DET.ID_DEVOLUCION
               AND DEV.ESTADO IN ('REGISTRADA','CONFIRMADA')
            GROUP BY DET.ID_HERRAMIENTA_ENTREGA_DETALLE
        ) ACUM
            ON ACUM.ID_HERRAMIENTA_ENTREGA_DETALLE = TMP.ID_DETALLE
        WHERE ORIG.id_detalle IS NULL
           OR TMP.CANTIDAD >
              ORIG.cantidad - COALESCE(ACUM.RESERVADA, 0);
    END IF;

    IF V_INVALIDOS > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Un elemento no pertenece a la entrega o supera la cantidad disponible.';
    END IF;

    INSERT INTO bbf_devoluciones (
        TIPO_DEVOLUCION,
        ID_EMPLEADO,
        ID_DOTACION_ENTREGA,
        ID_HERRAMIENTA_ENTREGA,
        FECHA_DEVOLUCION,
        ESTADO,
        MOTIVO,
        OBSERVACIONES,
        ID_REGISTRADO_POR
    )
    VALUES (
        V_TIPO,
        P_ID_EMPLEADO,
        IF(V_TIPO = 'DOTACION', P_ID_ENTREGA, NULL),
        IF(V_TIPO = 'HERRAMIENTA', P_ID_ENTREGA, NULL),
        COALESCE(P_FECHA_DEVOLUCION, CURRENT_DATE()),
        'REGISTRADA',
        TRIM(P_MOTIVO),
        NULLIF(TRIM(P_OBSERVACIONES), ''),
        P_ID_REGISTRADO_POR
    );

    SET V_ID_DEVOLUCION = LAST_INSERT_ID();

    IF V_TIPO = 'DOTACION' THEN
        INSERT INTO bbf_devolucion_detalle (
            ID_DEVOLUCION,
            ID_DOTACION_ENTREGA_DETALLE,
            CANTIDAD_DEVUELTA,
            ESTADO_ELEMENTO,
            OBSERVACIONES
        )
        SELECT
            V_ID_DEVOLUCION,
            ID_DETALLE,
            CANTIDAD,
            ESTADO_ELEMENTO,
            OBSERVACIONES
        FROM TMP_DEV_DETALLES;
    ELSE
        INSERT INTO bbf_devolucion_detalle (
            ID_DEVOLUCION,
            ID_HERRAMIENTA_ENTREGA_DETALLE,
            CANTIDAD_DEVUELTA,
            ESTADO_ELEMENTO,
            OBSERVACIONES
        )
        SELECT
            V_ID_DEVOLUCION,
            ID_DETALLE,
            CANTIDAD,
            ESTADO_ELEMENTO,
            OBSERVACIONES
        FROM TMP_DEV_DETALLES;
    END IF;

    INSERT INTO bbf_devolucion_evidencias (
        ID_DEVOLUCION,
        TIPO_EVIDENCIA,
        NOMBRE_ARCHIVO,
        NOMBRE_ORIGINAL,
        ARCHIVO_URL,
        ARCHIVO_RUTA,
        MIME_TYPE,
        PESO_BYTES
    )
    SELECT
        V_ID_DEVOLUCION,
        TIPO_EVIDENCIA,
        NOMBRE_ARCHIVO,
        NOMBRE_ORIGINAL,
        ARCHIVO_URL,
        ARCHIVO_RUTA,
        MIME_TYPE,
        PESO_BYTES
    FROM TMP_DEV_EVIDENCIAS;

    COMMIT;

    DROP TEMPORARY TABLE IF EXISTS TMP_DEV_DETALLES;
    DROP TEMPORARY TABLE IF EXISTS TMP_DEV_EVIDENCIAS;

    SELECT
        V_ID_DEVOLUCION AS ID_DEVOLUCION,
        'REGISTRADA' AS ESTADO,
        'Devolución registrada correctamente.' AS MENSAJE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DEVOLUCION_OBTENER` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DEVOLUCION_OBTENER`(
        IN P_ID_DEVOLUCION INT
    )
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM bbf_devoluciones
        WHERE ID_DEVOLUCION =
              P_ID_DEVOLUCION
    ) THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'La devolucion no existe.';
    END IF;

    SELECT
        DEV.*,
        E.NUMERO_DOCUMENTO,

        CONCAT_WS(
            ' ',
            E.NOMBRES,
            E.APELLIDOS
        ) AS NOMBRE_COMPLETO

    FROM bbf_devoluciones DEV

    INNER JOIN bbf_empleados E
        ON E.ID_EMPLEADO =
           DEV.ID_EMPLEADO

    WHERE DEV.ID_DEVOLUCION =
          P_ID_DEVOLUCION;

    SELECT
        DET.ID_DEVOLUCION_DETALLE,
        DET.ID_DEVOLUCION,

        DET.ID_DOTACION_ENTREGA_DETALLE,
        DET.ID_HERRAMIENTA_ENTREGA_DETALLE,

        DD.ID_DOTACION_ARTICULO,
        DA.CODIGO AS CODIGO_ARTICULO,

        COALESCE(
            DA.NOMBRE,
            TD.NOMBRE,
            H.nombre
        ) AS ELEMENTO,

        TD.NOMBRE AS TIPO_DOTACION,

        T.TALLA,

        DET.CANTIDAD_DEVUELTA,
        DET.ESTADO_ELEMENTO,
        DET.OBSERVACIONES,
        DET.CREATED_AT,
        DET.UPDATED_AT

    FROM bbf_devolucion_detalle DET

    LEFT JOIN bbf_dotacion_entrega_detalle DD
        ON DD.ID_DOTACION_ENTREGA_DETALLE =
           DET.ID_DOTACION_ENTREGA_DETALLE

    LEFT JOIN bbf_dotacion_articulos DA
        ON DA.ID_DOTACION_ARTICULO =
           DD.ID_DOTACION_ARTICULO

    LEFT JOIN bbf_tipos_dotacion TD
        ON TD.ID_TIPO_DOTACION =
           DD.ID_TIPO_DOTACION

    LEFT JOIN bbf_tallas_dotacion T
        ON T.ID_TALLA_DOTACION =
           DD.ID_TALLA_DOTACION

    LEFT JOIN bbf_herramientas_entrega_detalle HD
        ON HD.id_detalle =
           DET.ID_HERRAMIENTA_ENTREGA_DETALLE

    LEFT JOIN bbf_herramientas H
        ON H.id_herramienta =
           HD.id_herramienta

    WHERE DET.ID_DEVOLUCION =
          P_ID_DEVOLUCION

    ORDER BY
        ELEMENTO ASC;

    SELECT
        ID_DEVOLUCION_EVIDENCIA,
        ID_DEVOLUCION,
        TIPO_EVIDENCIA,
        NOMBRE_ARCHIVO,
        NOMBRE_ORIGINAL,
        ARCHIVO_URL,
        ARCHIVO_RUTA,
        MIME_TYPE,
        PESO_BYTES,
        CREATED_AT

    FROM bbf_devolucion_evidencias

    WHERE ID_DEVOLUCION =
          P_ID_DEVOLUCION

    ORDER BY
        ID_DEVOLUCION_EVIDENCIA ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOMINIOS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DOMINIOS_LISTAR`(
    IN P_SOLO_ACTIVOS TINYINT
)
BEGIN
    SELECT
        ID_DOMINIO,
        DOMINIO,
        DESCRIPCION,
        ACTIVO,
        CREATED_AT,
        UPDATED_AT
    FROM bbf_dominios_autorizados
    WHERE P_SOLO_ACTIVOS = 0 OR ACTIVO = 1
    ORDER BY DOMINIO ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOMINIOS_VALIDAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DOMINIOS_VALIDAR`(
    IN P_CORREO VARCHAR(150)
)
BEGIN
    DECLARE V_DOMINIO VARCHAR(150);

    SET V_DOMINIO = SUBSTRING_INDEX(P_CORREO, '@', -1);

    SELECT
        D.ID_DOMINIO,
        D.DOMINIO,
        D.ACTIVO,
        CASE
            WHEN D.ID_DOMINIO IS NOT NULL AND D.ACTIVO = 1 THEN 1
            ELSE 0
        END AS ES_VALIDO
    FROM bbf_dominios_autorizados D
    WHERE D.DOMINIO = V_DOMINIO
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_ARTICULOS_CARGUE_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DOTACION_ARTICULOS_CARGUE_LISTAR`()
BEGIN
    SELECT
        AC.`ID_DOTACION_ARTICULO_ALIAS`,
        AC.`ENCABEZADO_XLSX`,
        DA.`ID_DOTACION_ARTICULO`,
        DA.`CODIGO` AS `CODIGO_ARTICULO`,
        DA.`NOMBRE` AS `ARTICULO`,
        DA.`GENERO`,
        DA.`UNIDAD_MEDIDA`,
        DA.`ID_TIPO_DOTACION`,
        TD.`NOMBRE` AS `TIPO_DOTACION`,
        TD.`REQUIERE_TALLA`
    FROM `bbf_dotacion_articulo_alias_cargue` AC
    INNER JOIN `bbf_dotacion_articulos` DA
        ON DA.`ID_DOTACION_ARTICULO` = AC.`ID_DOTACION_ARTICULO`
    INNER JOIN `bbf_tipos_dotacion` TD
        ON TD.`ID_TIPO_DOTACION` = DA.`ID_TIPO_DOTACION`
    WHERE AC.`ACTIVO` = 1
      AND DA.`ACTIVO` = 1
      AND DA.`ES_LEGACY` = 0
      AND TD.`ACTIVO` = 1
    ORDER BY AC.`ID_DOTACION_ARTICULO_ALIAS`;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_ARTICULOS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DOTACION_ARTICULOS_LISTAR`(
    IN P_ID_TIPO_DOTACION INT,
    IN P_GENERO VARCHAR(20),
    IN P_INCLUIR_INACTIVOS TINYINT
)
BEGIN
    DECLARE V_GENERO VARCHAR(20);

    SET V_GENERO =
        NULLIF(
            UPPER(TRIM(P_GENERO)),
            ''
        );

    IF V_GENERO IS NOT NULL
       AND V_GENERO NOT IN (
           'HOMBRE',
           'MUJER',
           'UNISEX',
           'NO_APLICA'
       ) THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'El genero debe ser HOMBRE, MUJER, UNISEX o NO_APLICA.';
    END IF;

    SELECT
        DA.ID_DOTACION_ARTICULO,
        DA.CODIGO,
        DA.NOMBRE AS ARTICULO,
        DA.DESCRIPCION,
        DA.GENERO,
        DA.UNIDAD_MEDIDA,

        DA.ID_TIPO_DOTACION,
        TD.NOMBRE AS TIPO_DOTACION,
        TD.REQUIERE_TALLA,

        DA.ACTIVO,
        DA.CREATED_AT,
        DA.UPDATED_AT

    FROM bbf_dotacion_articulos DA

    INNER JOIN bbf_tipos_dotacion TD
        ON TD.ID_TIPO_DOTACION =
           DA.ID_TIPO_DOTACION

    WHERE DA.ES_LEGACY = 0

      AND (
          IFNULL(P_INCLUIR_INACTIVOS, 0) = 1
          OR DA.ACTIVO = 1
      )

      AND (
          P_ID_TIPO_DOTACION IS NULL
          OR P_ID_TIPO_DOTACION = 0
          OR DA.ID_TIPO_DOTACION =
             P_ID_TIPO_DOTACION
      )

      AND (
          V_GENERO IS NULL
          OR DA.GENERO = V_GENERO
          OR (
              V_GENERO IN ('HOMBRE', 'MUJER')
              AND DA.GENERO = 'UNISEX'
          )
          OR DA.GENERO = 'NO_APLICA'
      )

    ORDER BY
        TD.NOMBRE ASC,
        DA.NOMBRE ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_ARTICULO_TALLAS_CATALOGO_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DOTACION_ARTICULO_TALLAS_CATALOGO_LISTAR`(
    IN P_ID_DOTACION_ARTICULO INT
)
BEGIN
    SELECT
        DA.`ID_DOTACION_ARTICULO`,
        DA.`CODIGO` AS `CODIGO_ARTICULO`,
        DA.`NOMBRE` AS `ARTICULO`,
        DA.`ID_TIPO_DOTACION`,
        TD.`NOMBRE` AS `TIPO_DOTACION`,
        T.`ID_TALLA_DOTACION`,
        T.`TALLA`,
        T.`DESCRIPCION`,
        T.`ORDEN`
    FROM `bbf_dotacion_articulos` DA
    INNER JOIN `bbf_tipos_dotacion` TD
        ON TD.`ID_TIPO_DOTACION` = DA.`ID_TIPO_DOTACION`
    INNER JOIN `bbf_tallas_dotacion` T
        ON T.`ID_TIPO_DOTACION` = DA.`ID_TIPO_DOTACION`
       AND T.`ACTIVO` = 1
    WHERE DA.`ID_DOTACION_ARTICULO` = P_ID_DOTACION_ARTICULO
      AND DA.`ACTIVO` = 1
      AND DA.`ES_LEGACY` = 0
      AND TD.`ACTIVO` = 1
    ORDER BY T.`ORDEN`, T.`TALLA`;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_ARTICULO_TALLAS_EMPLEADO_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DOTACION_ARTICULO_TALLAS_EMPLEADO_LISTAR`(
    IN P_ID_EMPLEADO INT,
    IN P_INCLUIR_SIN_TALLA TINYINT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM `bbf_empleados`
        WHERE `ID_EMPLEADO` = P_ID_EMPLEADO
          AND IFNULL(`ELIMINADO`, 0) = 0
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El empleado no existe o fue eliminado.';
    END IF;

    SELECT
        DA.`ID_DOTACION_ARTICULO`,
        DA.`CODIGO` AS `CODIGO_ARTICULO`,
        DA.`NOMBRE` AS `ARTICULO`,
        DA.`GENERO`,
        DA.`UNIDAD_MEDIDA`,
        DA.`ID_TIPO_DOTACION`,
        TD.`NOMBRE` AS `TIPO_DOTACION`,
        TD.`REQUIERE_TALLA`,
        EAT.`ID_EMPLEADO_DOTACION_ARTICULO_TALLA`,
        EAT.`ID_TALLA_DOTACION` AS `ID_TALLA_ESPECIFICA`,
        TE.`TALLA` AS `TALLA_ESPECIFICA`,
        EFT.`ID_TALLA_DOTACION` AS `ID_TALLA_FAMILIAR`,
        TF.`TALLA` AS `TALLA_FAMILIAR`,
        COALESCE(EAT.`ID_TALLA_DOTACION`, EFT.`ID_TALLA_DOTACION`) AS `ID_TALLA_EFECTIVA`,
        COALESCE(TE.`TALLA`, TF.`TALLA`) AS `TALLA_EFECTIVA`,
        CASE
            WHEN EAT.`ID_TALLA_DOTACION` IS NOT NULL THEN 'ARTICULO'
            WHEN EFT.`ID_TALLA_DOTACION` IS NOT NULL THEN 'FAMILIA'
            ELSE 'SIN_TALLA'
        END AS `ORIGEN_TALLA`,
        EAT.`OBSERVACIONES`
    FROM `bbf_dotacion_articulos` DA
    INNER JOIN `bbf_tipos_dotacion` TD
        ON TD.`ID_TIPO_DOTACION` = DA.`ID_TIPO_DOTACION`
    LEFT JOIN `bbf_empleado_dotacion_articulo_tallas` EAT
        ON EAT.`ID_EMPLEADO` = P_ID_EMPLEADO
       AND EAT.`ID_DOTACION_ARTICULO` = DA.`ID_DOTACION_ARTICULO`
    LEFT JOIN `bbf_tallas_dotacion` TE
        ON TE.`ID_TALLA_DOTACION` = EAT.`ID_TALLA_DOTACION`
    LEFT JOIN `bbf_empleado_dotacion_tallas` EFT
        ON EFT.`ID_EMPLEADO` = P_ID_EMPLEADO
       AND EFT.`ID_TIPO_DOTACION` = DA.`ID_TIPO_DOTACION`
    LEFT JOIN `bbf_tallas_dotacion` TF
        ON TF.`ID_TALLA_DOTACION` = EFT.`ID_TALLA_DOTACION`
    WHERE DA.`ACTIVO` = 1
      AND DA.`ES_LEGACY` = 0
      AND TD.`ACTIVO` = 1
      AND (
          IFNULL(P_INCLUIR_SIN_TALLA, 0) = 1
          OR COALESCE(EAT.`ID_TALLA_DOTACION`, EFT.`ID_TALLA_DOTACION`) IS NOT NULL
      )
    ORDER BY TD.`NOMBRE`, DA.`NOMBRE`;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_ARTICULO_TALLA_GUARDAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DOTACION_ARTICULO_TALLA_GUARDAR`(
    IN P_ID_EMPLEADO INT,
    IN P_ID_DOTACION_ARTICULO INT,
    IN P_ID_TALLA_DOTACION INT,
    IN P_OBSERVACIONES VARCHAR(250),
    IN P_ID_USUARIO INT
)
BEGIN
    DECLARE V_ID_TIPO_DOTACION INT DEFAULT NULL;

    IF NOT EXISTS (
        SELECT 1 FROM `bbf_empleados`
        WHERE `ID_EMPLEADO` = P_ID_EMPLEADO
          AND IFNULL(`ELIMINADO`, 0) = 0
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El empleado no existe o fue eliminado.';
    END IF;

    SELECT DA.`ID_TIPO_DOTACION`
      INTO V_ID_TIPO_DOTACION
    FROM `bbf_dotacion_articulos` DA
    INNER JOIN `bbf_tipos_dotacion` TD
        ON TD.`ID_TIPO_DOTACION` = DA.`ID_TIPO_DOTACION`
    WHERE DA.`ID_DOTACION_ARTICULO` = P_ID_DOTACION_ARTICULO
      AND DA.`ACTIVO` = 1
      AND DA.`ES_LEGACY` = 0
      AND TD.`ACTIVO` = 1
      AND TD.`REQUIERE_TALLA` = 1
    LIMIT 1;

    IF V_ID_TIPO_DOTACION IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El artículo no existe, está inactivo, es histórico o no utiliza talla.';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM `bbf_tallas_dotacion`
        WHERE `ID_TALLA_DOTACION` = P_ID_TALLA_DOTACION
          AND `ID_TIPO_DOTACION` = V_ID_TIPO_DOTACION
          AND `ACTIVO` = 1
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La talla no está activa o no pertenece a la familia del artículo.';
    END IF;

    IF P_ID_USUARIO IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM `bbf_usuarios` WHERE `ID_USUARIO` = P_ID_USUARIO
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El usuario que actualiza la talla no existe.';
    END IF;

    INSERT INTO `bbf_empleado_dotacion_articulo_tallas` (
        `ID_EMPLEADO`, `ID_DOTACION_ARTICULO`, `ID_TIPO_DOTACION`,
        `ID_TALLA_DOTACION`, `OBSERVACIONES`, `ACTUALIZADO_POR_USUARIO`
    ) VALUES (
        P_ID_EMPLEADO, P_ID_DOTACION_ARTICULO, V_ID_TIPO_DOTACION,
        P_ID_TALLA_DOTACION, NULLIF(TRIM(P_OBSERVACIONES), ''), P_ID_USUARIO
    )
    ON DUPLICATE KEY UPDATE
        `ID_TIPO_DOTACION` = VALUES(`ID_TIPO_DOTACION`),
        `ID_TALLA_DOTACION` = VALUES(`ID_TALLA_DOTACION`),
        `OBSERVACIONES` = VALUES(`OBSERVACIONES`),
        `ACTUALIZADO_POR_USUARIO` = VALUES(`ACTUALIZADO_POR_USUARIO`),
        `UPDATED_AT` = CURRENT_TIMESTAMP;

    SELECT
        EAT.`ID_EMPLEADO_DOTACION_ARTICULO_TALLA`,
        EAT.`ID_EMPLEADO`,
        EAT.`ID_DOTACION_ARTICULO`,
        DA.`CODIGO` AS `CODIGO_ARTICULO`,
        DA.`NOMBRE` AS `ARTICULO`,
        EAT.`ID_TIPO_DOTACION`,
        TD.`NOMBRE` AS `TIPO_DOTACION`,
        EAT.`ID_TALLA_DOTACION`,
        T.`TALLA`,
        EAT.`OBSERVACIONES`,
        EAT.`ACTUALIZADO_POR_USUARIO`,
        EAT.`CREATED_AT`,
        EAT.`UPDATED_AT`
    FROM `bbf_empleado_dotacion_articulo_tallas` EAT
    INNER JOIN `bbf_dotacion_articulos` DA
        ON DA.`ID_DOTACION_ARTICULO` = EAT.`ID_DOTACION_ARTICULO`
    INNER JOIN `bbf_tipos_dotacion` TD
        ON TD.`ID_TIPO_DOTACION` = EAT.`ID_TIPO_DOTACION`
    INNER JOIN `bbf_tallas_dotacion` T
        ON T.`ID_TALLA_DOTACION` = EAT.`ID_TALLA_DOTACION`
    WHERE EAT.`ID_EMPLEADO` = P_ID_EMPLEADO
      AND EAT.`ID_DOTACION_ARTICULO` = P_ID_DOTACION_ARTICULO;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_COMBINACIONES_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DOTACION_COMBINACIONES_LISTAR`()
BEGIN

    SELECT
        C.ID_DOTACION_COMBINACION,

        C.CODIGO,

        C.NOMBRE,

        C.DESCRIPCION,

        C.ACTIVO

    FROM bbf_dotacion_combinaciones C

    WHERE C.ACTIVO = 1

    ORDER BY
        C.ID_DOTACION_COMBINACION ASC;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_COMBINACION_DETALLE_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DOTACION_COMBINACION_DETALLE_LISTAR`(
    IN P_ID_DOTACION_COMBINACION INT
)
BEGIN

    SELECT
        CD.ID_DOTACION_COMBINACION_DETALLE,

        CD.ID_DOTACION_COMBINACION,

        C.CODIGO
            AS CODIGO_COMBINACION,

        C.NOMBRE
            AS COMBINACION,

        CD.ID_TIPO_DOTACION,

        TD.NOMBRE
            AS TIPO_DOTACION,

        TD.REQUIERE_TALLA,

        CD.CANTIDAD,

        CD.ORDEN,

        CD.ACTIVO

    FROM bbf_dotacion_combinacion_detalle CD

    INNER JOIN bbf_dotacion_combinaciones C
        ON C.ID_DOTACION_COMBINACION =
           CD.ID_DOTACION_COMBINACION

    INNER JOIN bbf_tipos_dotacion TD
        ON TD.ID_TIPO_DOTACION =
           CD.ID_TIPO_DOTACION

    WHERE CD.ID_DOTACION_COMBINACION =
          P_ID_DOTACION_COMBINACION

      AND CD.ACTIVO = 1

      AND C.ACTIVO = 1

      AND TD.ACTIVO = 1

    ORDER BY
        CD.ORDEN ASC,
        TD.NOMBRE ASC;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_COTIZACION_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DOTACION_COTIZACION_LISTAR`(
    IN P_ID_AREA INT,
    IN P_ID_CARGO INT,
    IN P_ID_EMPLEADO INT
)
BEGIN
    WITH `ULTIMAS_ENTREGAS` AS (
        SELECT
            DE.`ID_DOTACION_ENTREGA`,
            DE.`ID_EMPLEADO`,
            DE.`FECHA_ENTREGA`,
            DE.`TIPO_ENTREGA`,
            DE.`FECHA_CONFIRMACION`,
            DD.`ID_DOTACION_ENTREGA_DETALLE`,
            DD.`ID_DOTACION_ARTICULO`,
            DD.`ID_TIPO_DOTACION`,
            DD.`ID_TALLA_DOTACION`,
            DD.`CANTIDAD`,
            DD.`OBSERVACIONES` AS `OBSERVACIONES_ULTIMA_ENTREGA`,
            TH.`TALLA` AS `TALLA_ULTIMA_ENTREGA`,
            ROW_NUMBER() OVER (
                PARTITION BY DE.`ID_EMPLEADO`, DD.`ID_DOTACION_ARTICULO`
                ORDER BY
                    DE.`FECHA_ENTREGA` DESC,
                    DE.`ID_DOTACION_ENTREGA` DESC,
                    DD.`ID_DOTACION_ENTREGA_DETALLE` DESC
            ) AS `NUMERO_FILA`
        FROM `bbf_dotacion_entregas` DE
        INNER JOIN `bbf_dotacion_entrega_detalle` DD
            ON DD.`ID_DOTACION_ENTREGA` = DE.`ID_DOTACION_ENTREGA`
           AND IFNULL(DD.`ELIMINADO`, 0) = 0
        LEFT JOIN `bbf_tallas_dotacion` TH
            ON TH.`ID_TALLA_DOTACION` = DD.`ID_TALLA_DOTACION`
           AND TH.`ID_TIPO_DOTACION` = DD.`ID_TIPO_DOTACION`
        WHERE DE.`ESTADO` = 'ENTREGADA'
          AND IFNULL(DE.`ELIMINADO`, 0) = 0
          AND DD.`ID_DOTACION_ARTICULO` IS NOT NULL
    )
    SELECT
        E.`ID_EMPLEADO`,
        E.`NUMERO_DOCUMENTO`,
        CONCAT_WS(' ', E.`NOMBRES`, E.`APELLIDOS`) AS `NOMBRE_COMPLETO`,
        E.`ID_AREA`,
        A.`NOMBRE` AS `AREA`,
        E.`ID_CARGO`,
        C.`NOMBRE` AS `CARGO`,

        DA.`ID_DOTACION_ARTICULO`,
        DA.`CODIGO` AS `CODIGO_ARTICULO`,
        DA.`NOMBRE` AS `ARTICULO`,
        DA.`GENERO`,
        DA.`UNIDAD_MEDIDA`,
        TD.`ID_TIPO_DOTACION`,
        TD.`NOMBRE` AS `TIPO_DOTACION`,

        COALESCE(
            EAT.`ID_TALLA_DOTACION`,
            EDT.`ID_TALLA_DOTACION`
        ) AS `ID_TALLA_ACTUAL`,

        COALESCE(
            TA.`TALLA`,
            TF.`TALLA`
        ) AS `TALLA_ACTUAL`,

        CASE
            WHEN EAT.`ID_TALLA_DOTACION` IS NOT NULL THEN 'ESPECIFICA'
            WHEN EDT.`ID_TALLA_DOTACION` IS NOT NULL THEN 'HEREDADA_FAMILIA'
            ELSE 'SIN_REGISTRAR'
        END AS `ORIGEN_TALLA`,

        UE.`ID_DOTACION_ENTREGA` AS `ID_ULTIMA_ENTREGA`,
        UE.`FECHA_ENTREGA` AS `FECHA_ULTIMA_ENTREGA`,
        UE.`TIPO_ENTREGA` AS `TIPO_ULTIMA_ENTREGA`,
        UE.`FECHA_CONFIRMACION`,
        UE.`ID_TALLA_DOTACION` AS `ID_TALLA_ULTIMA_ENTREGA`,
        UE.`TALLA_ULTIMA_ENTREGA`,
        UE.`CANTIDAD` AS `CANTIDAD_ULTIMA_ENTREGA`,

        CASE
            WHEN COALESCE(EAT.`ID_TALLA_DOTACION`, EDT.`ID_TALLA_DOTACION`) IS NULL
                THEN 'TALLA PENDIENTE'
            WHEN UE.`ID_DOTACION_ENTREGA` IS NULL
                THEN 'SIN ENTREGA PREVIA'
            WHEN COALESCE(TA.`TALLA`, TF.`TALLA`) IS NOT NULL
             AND UE.`TALLA_ULTIMA_ENTREGA` IS NOT NULL
             AND COALESCE(TA.`TALLA`, TF.`TALLA`) <> UE.`TALLA_ULTIMA_ENTREGA`
                THEN 'TALLA DIFERENTE'
            ELSE 'CON ENTREGA PREVIA'
        END AS `ESTADO_INFORMACION`,

        COALESCE(
            EAT.`OBSERVACIONES`,
            EDT.`OBSERVACIONES`
        ) AS `OBSERVACIONES_TALLA`,

        UE.`OBSERVACIONES_ULTIMA_ENTREGA`

    FROM `bbf_empleados` E

    INNER JOIN `bbf_dotacion_articulos` DA
        ON DA.`ACTIVO` = 1
       AND DA.`ES_LEGACY` = 0

    INNER JOIN `bbf_tipos_dotacion` TD
        ON TD.`ID_TIPO_DOTACION` = DA.`ID_TIPO_DOTACION`
       AND TD.`ACTIVO` = 1
       AND TD.`REQUIERE_TALLA` = 1

    LEFT JOIN `bbf_empleado_dotacion_articulo_tallas` EAT
        ON EAT.`ID_EMPLEADO` = E.`ID_EMPLEADO`
       AND EAT.`ID_DOTACION_ARTICULO` = DA.`ID_DOTACION_ARTICULO`

    LEFT JOIN `bbf_tallas_dotacion` TA
        ON TA.`ID_TALLA_DOTACION` = EAT.`ID_TALLA_DOTACION`
       AND TA.`ID_TIPO_DOTACION` = DA.`ID_TIPO_DOTACION`

    LEFT JOIN `bbf_empleado_dotacion_tallas` EDT
        ON EDT.`ID_EMPLEADO` = E.`ID_EMPLEADO`
       AND EDT.`ID_TIPO_DOTACION` = DA.`ID_TIPO_DOTACION`

    LEFT JOIN `bbf_tallas_dotacion` TF
        ON TF.`ID_TALLA_DOTACION` = EDT.`ID_TALLA_DOTACION`
       AND TF.`ID_TIPO_DOTACION` = DA.`ID_TIPO_DOTACION`

    LEFT JOIN `bbf_areas` A
        ON A.`ID_AREA` = E.`ID_AREA`

    LEFT JOIN `bbf_cargos` C
        ON C.`ID_CARGO` = E.`ID_CARGO`

    LEFT JOIN `ULTIMAS_ENTREGAS` UE
        ON UE.`ID_EMPLEADO` = E.`ID_EMPLEADO`
       AND UE.`ID_DOTACION_ARTICULO` = DA.`ID_DOTACION_ARTICULO`
       AND UE.`NUMERO_FILA` = 1

    WHERE E.`ESTADO_EMPLEADO` = 'ACTIVO'
      AND IFNULL(E.`ELIMINADO`, 0) = 0
      AND (P_ID_AREA IS NULL OR P_ID_AREA = 0 OR E.`ID_AREA` = P_ID_AREA)
      AND (P_ID_CARGO IS NULL OR P_ID_CARGO = 0 OR E.`ID_CARGO` = P_ID_CARGO)
      AND (P_ID_EMPLEADO IS NULL OR P_ID_EMPLEADO = 0 OR E.`ID_EMPLEADO` = P_ID_EMPLEADO)

    ORDER BY
        A.`NOMBRE` ASC,
        C.`NOMBRE` ASC,
        E.`NOMBRES` ASC,
        E.`APELLIDOS` ASC,
        TD.`NOMBRE` ASC,
        DA.`NOMBRE` ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_COTIZACION_POR_COMPRAR_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DOTACION_COTIZACION_POR_COMPRAR_LISTAR`(
        IN P_ID_AREA INT,
        IN P_ID_CARGO INT,
        IN P_ID_EMPLEADO INT
    )
BEGIN
    SELECT
        DE.ID_DOTACION_ENTREGA,
        DE.CREATED_AT AS FECHA_SOLICITUD,
        DE.FECHA_ENTREGA AS FECHA_REQUERIDA,

        E.ID_EMPLEADO,
        E.NUMERO_DOCUMENTO,

        CONCAT_WS(
            ' ',
            E.NOMBRES,
            E.APELLIDOS
        ) AS NOMBRE_COMPLETO,

        E.ID_AREA,
        A.NOMBRE AS AREA,

        E.ID_CARGO,
        CARGO.NOMBRE AS CARGO,

        DE.TIPO_ENTREGA,

        DE.ID_DOTACION_COMBINACION,
        COMB.CODIGO AS CODIGO_COMBINACION,
        COMB.NOMBRE AS NOMBRE_COMBINACION,

        DD.ID_DOTACION_ENTREGA_DETALLE,

        DD.ID_DOTACION_ARTICULO,
        DA.CODIGO AS CODIGO_ARTICULO,

        COALESCE(
            DA.NOMBRE,
            TD.NOMBRE
        ) AS ARTICULO,

        DA.GENERO,
        DA.UNIDAD_MEDIDA,

        DD.ID_TIPO_DOTACION,
        TD.NOMBRE AS TIPO_DOTACION,

        DD.ID_TALLA_DOTACION,
        T.TALLA,

        DD.CANTIDAD,

        DE.OBSERVACIONES
            AS OBSERVACIONES_SOLICITUD,

        DD.OBSERVACIONES
            AS OBSERVACIONES_DETALLE,

        DE.ESTADO

    FROM bbf_dotacion_entregas DE

    INNER JOIN bbf_dotacion_entrega_detalle DD
        ON DD.ID_DOTACION_ENTREGA =
           DE.ID_DOTACION_ENTREGA

       AND IFNULL(
           DD.ELIMINADO,
           0
       ) = 0

    INNER JOIN bbf_empleados E
        ON E.ID_EMPLEADO =
           DE.ID_EMPLEADO

       AND IFNULL(
           E.ELIMINADO,
           0
       ) = 0

    LEFT JOIN bbf_areas A
        ON A.ID_AREA =
           E.ID_AREA

    LEFT JOIN bbf_cargos CARGO
        ON CARGO.ID_CARGO =
           E.ID_CARGO

    INNER JOIN bbf_tipos_dotacion TD
        ON TD.ID_TIPO_DOTACION =
           DD.ID_TIPO_DOTACION

    LEFT JOIN bbf_dotacion_articulos DA
        ON DA.ID_DOTACION_ARTICULO =
           DD.ID_DOTACION_ARTICULO

    LEFT JOIN bbf_tallas_dotacion T
        ON T.ID_TALLA_DOTACION =
           DD.ID_TALLA_DOTACION

       AND T.ID_TIPO_DOTACION =
           DD.ID_TIPO_DOTACION

    LEFT JOIN bbf_dotacion_combinaciones COMB
        ON COMB.ID_DOTACION_COMBINACION =
           DE.ID_DOTACION_COMBINACION

    WHERE DE.ESTADO = 'POR_COMPRAR'
      AND IFNULL(DE.ELIMINADO, 0) = 0

      AND (
          P_ID_AREA IS NULL
          OR P_ID_AREA = 0
          OR E.ID_AREA = P_ID_AREA
      )

      AND (
          P_ID_CARGO IS NULL
          OR P_ID_CARGO = 0
          OR E.ID_CARGO = P_ID_CARGO
      )

      AND (
          P_ID_EMPLEADO IS NULL
          OR P_ID_EMPLEADO = 0
          OR E.ID_EMPLEADO = P_ID_EMPLEADO
      )

    ORDER BY
        COALESCE(
            DA.NOMBRE,
            TD.NOMBRE
        ) ASC,

        T.ORDEN ASC,
        A.NOMBRE ASC,
        CARGO.NOMBRE ASC,
        E.NOMBRES ASC,
        E.APELLIDOS ASC,
        DE.ID_DOTACION_ENTREGA ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_EMPLEADOS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DOTACION_EMPLEADOS_LISTAR`(
    IN P_TEXTO_BUSQUEDA VARCHAR(150),
    IN P_ID_AREA INT,
    IN P_ID_CARGO INT
)
BEGIN
    SELECT
        E.ID_EMPLEADO,
        E.NUMERO_DOCUMENTO,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS)
            AS NOMBRE_COMPLETO,
        E.CORREO,
        E.TELEFONO,
        E.ID_AREA,
        A.NOMBRE AS AREA,
        E.ID_CARGO,
        C.NOMBRE AS CARGO,
        E.ESTADO_EMPLEADO,

        COUNT(DISTINCT CASE
            WHEN DE.ESTADO = 'ENTREGADA'
            THEN DE.ID_DOTACION_ENTREGA
        END) AS TOTAL_ENTREGAS,

        COUNT(DISTINCT CASE
            WHEN DE.ESTADO = 'REGISTRADA'
             AND DE.FECHA_CONFIRMACION IS NULL
            THEN DE.ID_DOTACION_ENTREGA
        END) AS PENDIENTES,

        COUNT(DISTINCT CASE
            WHEN DE.ESTADO = 'POR_COMPRAR'
            THEN DE.ID_DOTACION_ENTREGA
        END) AS POR_COMPRAR,

        MAX(CASE
            WHEN DE.ESTADO = 'ENTREGADA'
            THEN DE.FECHA_ENTREGA
            ELSE NULL
        END) AS ULTIMA_ENTREGA,

        GROUP_CONCAT(
            DISTINCT CONCAT(
                TD.NOMBRE,
                ': ',
                IFNULL(T.TALLA, 'Sin talla')
            )
            ORDER BY TD.NOMBRE ASC
            SEPARATOR ' | '
        ) AS RESUMEN_TALLAS

    FROM bbf_empleados E

    LEFT JOIN bbf_areas A
        ON A.ID_AREA = E.ID_AREA

    LEFT JOIN bbf_cargos C
        ON C.ID_CARGO = E.ID_CARGO

    LEFT JOIN bbf_dotacion_entregas DE
        ON DE.ID_EMPLEADO = E.ID_EMPLEADO
       AND IFNULL(DE.ELIMINADO, 0) = 0

    LEFT JOIN bbf_tipos_dotacion TD
        ON TD.ACTIVO = 1

    LEFT JOIN bbf_empleado_dotacion_tallas EDT
        ON EDT.ID_EMPLEADO = E.ID_EMPLEADO
       AND EDT.ID_TIPO_DOTACION =
           TD.ID_TIPO_DOTACION

    LEFT JOIN bbf_tallas_dotacion T
        ON T.ID_TALLA_DOTACION =
           EDT.ID_TALLA_DOTACION

    WHERE E.ESTADO_EMPLEADO = 'ACTIVO'
      AND IFNULL(E.ELIMINADO, 0) = 0

      AND (
          P_ID_AREA IS NULL
          OR P_ID_AREA = 0
          OR E.ID_AREA = P_ID_AREA
      )

      AND (
          P_ID_CARGO IS NULL
          OR P_ID_CARGO = 0
          OR E.ID_CARGO = P_ID_CARGO
      )

      AND (
          P_TEXTO_BUSQUEDA IS NULL
          OR P_TEXTO_BUSQUEDA = ''
          OR E.NUMERO_DOCUMENTO LIKE
             CONCAT('%', P_TEXTO_BUSQUEDA, '%')
          OR E.NOMBRES LIKE
             CONCAT('%', P_TEXTO_BUSQUEDA, '%')
          OR E.APELLIDOS LIKE
             CONCAT('%', P_TEXTO_BUSQUEDA, '%')
          OR E.CORREO LIKE
             CONCAT('%', P_TEXTO_BUSQUEDA, '%')
      )

    GROUP BY
        E.ID_EMPLEADO,
        E.NUMERO_DOCUMENTO,
        E.NOMBRES,
        E.APELLIDOS,
        E.CORREO,
        E.TELEFONO,
        E.ID_AREA,
        A.NOMBRE,
        E.ID_CARGO,
        C.NOMBRE,
        E.ESTADO_EMPLEADO

    ORDER BY
        E.NOMBRES ASC,
        E.APELLIDOS ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_ENTREGAS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DOTACION_ENTREGAS_LISTAR`(
    IN P_ID_EMPLEADO INT,
    IN P_FECHA_INICIO DATE,
    IN P_FECHA_FIN DATE
)
BEGIN

    SELECT
        DE.ID_DOTACION_ENTREGA,

        DE.ID_EMPLEADO,

        E.NUMERO_DOCUMENTO,

        CONCAT(
            E.NOMBRES,
            ' ',
            E.APELLIDOS
        ) AS NOMBRE_COMPLETO,

        DE.FECHA_ENTREGA,

        DE.TIPO_ENTREGA,

        DE.ID_DOTACION_COMBINACION,

        C.CODIGO
            AS CODIGO_COMBINACION,

        C.NOMBRE
            AS NOMBRE_COMBINACION,

        DE.FECHA_CONFIRMACION,

        DE.ESTADO,

        DE.OBSERVACIONES,

        DE.OBSERVACION_CONFIRMACION,

        DE.FIRMA_URL,


        -- =============================================================
        -- EVIDENCIA
        -- =============================================================

        DE.EVIDENCIA_NOMBRE_ARCHIVO,

        DE.EVIDENCIA_NOMBRE_ORIGINAL,

        DE.EVIDENCIA_URL,

        DE.EVIDENCIA_RUTA,

        DE.EVIDENCIA_MIME_TYPE,

        DE.EVIDENCIA_PESO_BYTES,

        DE.EVIDENCIA_FECHA_CARGA,


        DE.ID_REGISTRADO_POR,

        UR.NOMBRE_USUARIO
            AS REGISTRADO_POR,

        DE.ID_CONFIRMADO_POR,

        UC.NOMBRE_USUARIO
            AS CONFIRMADO_POR,

        DE.CREATED_AT,

        DE.UPDATED_AT


    FROM bbf_dotacion_entregas DE

    INNER JOIN bbf_empleados E
        ON E.ID_EMPLEADO =
           DE.ID_EMPLEADO

    LEFT JOIN bbf_usuarios UR
        ON UR.ID_USUARIO =
           DE.ID_REGISTRADO_POR

    LEFT JOIN bbf_usuarios UC
        ON UC.ID_USUARIO =
           DE.ID_CONFIRMADO_POR

    LEFT JOIN bbf_dotacion_combinaciones C
        ON C.ID_DOTACION_COMBINACION =
           DE.ID_DOTACION_COMBINACION

    WHERE IFNULL(DE.ELIMINADO, 0) = 0

      AND (
          P_ID_EMPLEADO IS NULL
          OR P_ID_EMPLEADO = 0
          OR DE.ID_EMPLEADO =
             P_ID_EMPLEADO
      )

      AND (
          P_FECHA_INICIO IS NULL
          OR DE.FECHA_ENTREGA >=
             P_FECHA_INICIO
      )

      AND (
          P_FECHA_FIN IS NULL
          OR DE.FECHA_ENTREGA <=
             P_FECHA_FIN
      )

    ORDER BY
        DE.FECHA_ENTREGA DESC,
        DE.ID_DOTACION_ENTREGA DESC;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_ENTREGA_CONFIRMAR_POR_RRHH` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DOTACION_ENTREGA_CONFIRMAR_POR_RRHH`(
    IN P_ID_USUARIO_RRHH INT,
    IN P_ID_DOTACION_ENTREGA INT,
    IN P_OBSERVACION_CONFIRMACION VARCHAR(500)
)
BEGIN
    DECLARE V_ESTADO VARCHAR(50) DEFAULT NULL;
    DECLARE V_ELIMINADO TINYINT DEFAULT 0;
    DECLARE V_TOTAL_DETALLES INT DEFAULT 0;
    DECLARE V_DETALLES_SIN_ARTICULO INT DEFAULT 0;

    IF NOT EXISTS (
        SELECT 1
        FROM bbf_usuarios
        WHERE ID_USUARIO = P_ID_USUARIO_RRHH
          AND ESTADO = 'ACTIVO'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El usuario de Recursos Humanos no existe o esta inactivo.';
    END IF;

    SELECT ESTADO, ELIMINADO
    INTO V_ESTADO, V_ELIMINADO
    FROM bbf_dotacion_entregas
    WHERE ID_DOTACION_ENTREGA = P_ID_DOTACION_ENTREGA
    LIMIT 1;

    IF V_ESTADO IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La entrega de dotacion no existe.';
    END IF;

    IF IFNULL(V_ELIMINADO, 0) = 1 OR V_ESTADO = 'ANULADA' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede confirmar una entrega anulada o eliminada.';
    END IF;

    IF V_ESTADO = 'POR_COMPRAR' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La dotacion todavia se encuentra por comprar.';
    END IF;

    IF V_ESTADO = 'ENTREGADA' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La entrega ya fue confirmada anteriormente.';
    END IF;

    IF V_ESTADO <> 'REGISTRADA' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La entrega no se encuentra disponible para confirmacion.';
    END IF;

    SELECT
        COUNT(*),
        COALESCE(SUM(CASE WHEN ID_DOTACION_ARTICULO IS NULL THEN 1 ELSE 0 END), 0)
    INTO V_TOTAL_DETALLES, V_DETALLES_SIN_ARTICULO
    FROM bbf_dotacion_entrega_detalle
    WHERE ID_DOTACION_ENTREGA = P_ID_DOTACION_ENTREGA
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_TOTAL_DETALLES = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La entrega no contiene articulos para confirmar.';
    END IF;

    IF V_DETALLES_SIN_ARTICULO > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La entrega contiene detalles sin articulo asociado.';
    END IF;

    UPDATE bbf_dotacion_entregas
    SET ESTADO = 'ENTREGADA',
        FECHA_CONFIRMACION = CURRENT_TIMESTAMP,
        ID_CONFIRMADO_POR = P_ID_USUARIO_RRHH,
        OBSERVACION_CONFIRMACION = COALESCE(
            NULLIF(TRIM(P_OBSERVACION_CONFIRMACION), ''),
            'Entrega presencial confirmada por Recursos Humanos.'
        ),
        UPDATED_AT = CURRENT_TIMESTAMP
    WHERE ID_DOTACION_ENTREGA = P_ID_DOTACION_ENTREGA
      AND ESTADO = 'REGISTRADA'
      AND IFNULL(ELIMINADO, 0) = 0;

    SELECT
        DE.ID_DOTACION_ENTREGA,
        DE.ID_EMPLEADO,
        DE.FECHA_ENTREGA,
        DE.FECHA_CONFIRMACION,
        DE.ESTADO,
        DE.OBSERVACIONES,
        DE.OBSERVACION_CONFIRMACION,
        DE.FIRMA_URL,
        DE.ID_CONFIRMADO_POR
    FROM bbf_dotacion_entregas DE
    WHERE DE.ID_DOTACION_ENTREGA = P_ID_DOTACION_ENTREGA;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_ENTREGA_CONFIRMAR_RECIBIDO` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DOTACION_ENTREGA_CONFIRMAR_RECIBIDO`(
        IN P_ID_USUARIO INT,
        IN P_ID_DOTACION_ENTREGA INT,
        IN P_OBSERVACION_CONFIRMACION VARCHAR(500),
        IN P_FIRMA_URL VARCHAR(500)
    )
BEGIN
    DECLARE V_ID_EMPLEADO INT;
    DECLARE V_ID_EMPLEADO_ENTREGA INT;
    DECLARE V_ESTADO VARCHAR(50);
    DECLARE V_ELIMINADO TINYINT DEFAULT 0;

    DECLARE V_TOTAL_DETALLES INT DEFAULT 0;
    DECLARE V_DETALLES_SIN_ARTICULO INT DEFAULT 0;

    SELECT
        ID_EMPLEADO
    INTO
        V_ID_EMPLEADO
    FROM bbf_usuarios
    WHERE ID_USUARIO =
          P_ID_USUARIO
    LIMIT 1;

    IF V_ID_EMPLEADO IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'El usuario no tiene un empleado asociado.';
    END IF;

    SELECT
        ID_EMPLEADO,
        ESTADO,
        ELIMINADO
    INTO
        V_ID_EMPLEADO_ENTREGA,
        V_ESTADO,
        V_ELIMINADO
    FROM bbf_dotacion_entregas
    WHERE ID_DOTACION_ENTREGA =
          P_ID_DOTACION_ENTREGA
    LIMIT 1;

    IF V_ID_EMPLEADO_ENTREGA IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'La entrega de dotacion no existe.';
    END IF;

    IF IFNULL(V_ELIMINADO, 0) = 1
       OR V_ESTADO = 'ANULADA' THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'No se puede confirmar una entrega anulada.';
    END IF;

    IF V_ID_EMPLEADO_ENTREGA <>
       V_ID_EMPLEADO THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'No puede confirmar una entrega asociada a otro empleado.';
    END IF;

    IF V_ESTADO = 'POR_COMPRAR' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'La dotacion todavia se encuentra por comprar y no puede confirmarse.';
    END IF;

    IF V_ESTADO = 'ENTREGADA' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'La entrega ya fue confirmada anteriormente.';
    END IF;

    IF V_ESTADO <> 'REGISTRADA' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'La entrega no se encuentra disponible para confirmacion.';
    END IF;

    SELECT
        COUNT(*),

        SUM(
            CASE
                WHEN ID_DOTACION_ARTICULO IS NULL
                THEN 1
                ELSE 0
            END
        )
    INTO
        V_TOTAL_DETALLES,
        V_DETALLES_SIN_ARTICULO

    FROM bbf_dotacion_entrega_detalle

    WHERE ID_DOTACION_ENTREGA =
          P_ID_DOTACION_ENTREGA

      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_TOTAL_DETALLES = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'La entrega no contiene articulos para confirmar.';
    END IF;

    IF IFNULL(
        V_DETALLES_SIN_ARTICULO,
        0
    ) > 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'La entrega contiene detalles sin articulo de dotacion asociado.';
    END IF;

    UPDATE bbf_dotacion_entregas
    SET
        ESTADO = 'ENTREGADA',

        FECHA_CONFIRMACION =
            CURRENT_TIMESTAMP,

        ID_CONFIRMADO_POR =
            P_ID_USUARIO,

        OBSERVACION_CONFIRMACION =
            NULLIF(
                TRIM(P_OBSERVACION_CONFIRMACION),
                ''
            ),

        FIRMA_URL =
            NULLIF(
                TRIM(P_FIRMA_URL),
                ''
            ),

        UPDATED_AT =
            CURRENT_TIMESTAMP

    WHERE ID_DOTACION_ENTREGA =
          P_ID_DOTACION_ENTREGA

      AND ESTADO = 'REGISTRADA'
      AND IFNULL(ELIMINADO, 0) = 0;

    SELECT
        DE.ID_DOTACION_ENTREGA,
        DE.ID_EMPLEADO,
        DE.FECHA_ENTREGA,
        DE.FECHA_CONFIRMACION,
        DE.ESTADO,
        DE.OBSERVACIONES,
        DE.OBSERVACION_CONFIRMACION,
        DE.FIRMA_URL,
        DE.ID_CONFIRMADO_POR

    FROM bbf_dotacion_entregas DE

    WHERE DE.ID_DOTACION_ENTREGA =
          P_ID_DOTACION_ENTREGA;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_ENTREGA_CREAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DOTACION_ENTREGA_CREAR`(
    IN P_ID_EMPLEADO INT,
    IN P_FECHA_ENTREGA DATE,
    IN P_TIPO_ENTREGA VARCHAR(20),
    IN P_ID_DOTACION_COMBINACION INT,
    IN P_ID_REGISTRADO_POR INT,
    IN P_OBSERVACIONES TEXT,

    IN P_EVIDENCIA_NOMBRE_ARCHIVO VARCHAR(255),
    IN P_EVIDENCIA_NOMBRE_ORIGINAL VARCHAR(255),
    IN P_EVIDENCIA_URL VARCHAR(500),
    IN P_EVIDENCIA_RUTA VARCHAR(500),
    IN P_EVIDENCIA_MIME_TYPE VARCHAR(100),
    IN P_EVIDENCIA_PESO_BYTES BIGINT
)
BEGIN
    DECLARE V_EXISTE_EMPLEADO INT DEFAULT 0;
    DECLARE V_EXISTE_COMBINACION INT DEFAULT 0;
    DECLARE V_ID_DOTACION_ENTREGA INT DEFAULT NULL;
    DECLARE V_TIPO_ENTREGA VARCHAR(20);
    DECLARE V_TIENE_URL TINYINT DEFAULT 0;
    DECLARE V_TIENE_RUTA TINYINT DEFAULT 0;

    SET V_TIPO_ENTREGA =
        UPPER(TRIM(P_TIPO_ENTREGA));

    SELECT COUNT(*)
    INTO V_EXISTE_EMPLEADO
    FROM bbf_empleados
    WHERE ID_EMPLEADO = P_ID_EMPLEADO
      AND ESTADO_EMPLEADO = 'ACTIVO'
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_EXISTE_EMPLEADO = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'El empleado no existe, esta inactivo o fue eliminado.';
    END IF;

    IF P_FECHA_ENTREGA IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'La fecha de entrega es obligatoria.';
    END IF;

    IF V_TIPO_ENTREGA NOT IN (
        'ORDINARIA',
        'EXTRAORDINARIA'
    ) THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'El tipo de entrega debe ser ORDINARIA o EXTRAORDINARIA.';
    END IF;

    IF V_TIPO_ENTREGA = 'EXTRAORDINARIA'
       AND P_ID_DOTACION_COMBINACION IS NOT NULL THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'La entrega extraordinaria no debe tener una combinacion asociada.';
    END IF;

    IF V_TIPO_ENTREGA = 'ORDINARIA'
       AND P_ID_DOTACION_COMBINACION IS NOT NULL THEN

        SELECT COUNT(*)
        INTO V_EXISTE_COMBINACION
        FROM bbf_dotacion_combinaciones
        WHERE ID_DOTACION_COMBINACION =
              P_ID_DOTACION_COMBINACION
          AND ACTIVO = 1;

        IF V_EXISTE_COMBINACION = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'La combinacion seleccionada no existe o esta inactiva.';
        END IF;

        SELECT COUNT(*)
        INTO V_EXISTE_COMBINACION
        FROM bbf_dotacion_combinacion_detalle
        WHERE ID_DOTACION_COMBINACION =
              P_ID_DOTACION_COMBINACION
          AND ACTIVO = 1;

        IF V_EXISTE_COMBINACION = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'La combinacion seleccionada no contiene prendas activas.';
        END IF;
    END IF;

    SET V_TIENE_URL =
        CASE
            WHEN P_EVIDENCIA_URL IS NOT NULL
             AND TRIM(P_EVIDENCIA_URL) <> ''
            THEN 1
            ELSE 0
        END;

    SET V_TIENE_RUTA =
        CASE
            WHEN P_EVIDENCIA_RUTA IS NOT NULL
             AND TRIM(P_EVIDENCIA_RUTA) <> ''
            THEN 1
            ELSE 0
        END;

    IF P_EVIDENCIA_NOMBRE_ARCHIVO IS NULL
       OR TRIM(P_EVIDENCIA_NOMBRE_ARCHIVO) = '' THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'El nombre de la evidencia es obligatorio.';
    END IF;

    IF V_TIENE_URL = 0
       AND V_TIENE_RUTA = 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Debe registrar una URL externa o cargar un archivo como evidencia.';
    END IF;

    IF V_TIENE_URL = 1
       AND V_TIENE_RUTA = 1 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'La evidencia debe ser una URL externa o un archivo fisico, no ambos.';
    END IF;

    INSERT INTO bbf_dotacion_entregas
    (
        ID_EMPLEADO,
        FECHA_ENTREGA,
        TIPO_ENTREGA,
        ID_DOTACION_COMBINACION,
        ESTADO,
        OBSERVACIONES,
        ID_REGISTRADO_POR,

        EVIDENCIA_NOMBRE_ARCHIVO,
        EVIDENCIA_NOMBRE_ORIGINAL,
        EVIDENCIA_URL,
        EVIDENCIA_RUTA,
        EVIDENCIA_MIME_TYPE,
        EVIDENCIA_PESO_BYTES,
        EVIDENCIA_FECHA_CARGA
    )
    VALUES
    (
        P_ID_EMPLEADO,
        P_FECHA_ENTREGA,
        V_TIPO_ENTREGA,

        CASE
            WHEN V_TIPO_ENTREGA = 'ORDINARIA'
            THEN P_ID_DOTACION_COMBINACION
            ELSE NULL
        END,

        'REGISTRADA',
        NULLIF(TRIM(P_OBSERVACIONES), ''),
        P_ID_REGISTRADO_POR,

        NULLIF(
            TRIM(P_EVIDENCIA_NOMBRE_ARCHIVO),
            ''
        ),

        NULLIF(
            TRIM(P_EVIDENCIA_NOMBRE_ORIGINAL),
            ''
        ),

        NULLIF(
            TRIM(P_EVIDENCIA_URL),
            ''
        ),

        NULLIF(
            TRIM(P_EVIDENCIA_RUTA),
            ''
        ),

        P_EVIDENCIA_MIME_TYPE,
        P_EVIDENCIA_PESO_BYTES,
        CURRENT_TIMESTAMP
    );

    SET V_ID_DOTACION_ENTREGA =
        LAST_INSERT_ID();

    SELECT
        DE.ID_DOTACION_ENTREGA,
        DE.ID_EMPLEADO,
        DE.FECHA_ENTREGA,
        DE.TIPO_ENTREGA,

        DE.ID_DOTACION_COMBINACION,
        C.CODIGO AS CODIGO_COMBINACION,
        C.NOMBRE AS NOMBRE_COMBINACION,

        DE.ESTADO,
        DE.OBSERVACIONES,
        DE.ID_REGISTRADO_POR,

        DE.EVIDENCIA_NOMBRE_ARCHIVO,
        DE.EVIDENCIA_NOMBRE_ORIGINAL,
        DE.EVIDENCIA_URL,
        DE.EVIDENCIA_RUTA,
        DE.EVIDENCIA_MIME_TYPE,
        DE.EVIDENCIA_PESO_BYTES,
        DE.EVIDENCIA_FECHA_CARGA,

        DE.CREATED_AT

    FROM bbf_dotacion_entregas DE

    LEFT JOIN bbf_dotacion_combinaciones C
        ON C.ID_DOTACION_COMBINACION =
           DE.ID_DOTACION_COMBINACION

    WHERE DE.ID_DOTACION_ENTREGA =
          V_ID_DOTACION_ENTREGA;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_ENTREGA_CREAR_V2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DOTACION_ENTREGA_CREAR_V2`(
    IN P_ID_EMPLEADO INT,
    IN P_FECHA_ENTREGA DATE,
    IN P_TIPO_ENTREGA VARCHAR(20),
    IN P_ID_DOTACION_COMBINACION INT,
    IN P_ID_REGISTRADO_POR INT,
    IN P_OBSERVACIONES TEXT,
    IN P_ESTADO_INICIAL VARCHAR(20),

    IN P_EVIDENCIA_NOMBRE_ARCHIVO VARCHAR(255),
    IN P_EVIDENCIA_NOMBRE_ORIGINAL VARCHAR(255),
    IN P_EVIDENCIA_URL VARCHAR(500),
    IN P_EVIDENCIA_RUTA VARCHAR(500),
    IN P_EVIDENCIA_MIME_TYPE VARCHAR(100),
    IN P_EVIDENCIA_PESO_BYTES BIGINT
)
BEGIN
    DECLARE V_EXISTE_EMPLEADO INT DEFAULT 0;
    DECLARE V_EXISTE_COMBINACION INT DEFAULT 0;
    DECLARE V_ID_DOTACION_ENTREGA INT DEFAULT NULL;

    DECLARE V_TIPO_ENTREGA VARCHAR(20);
    DECLARE V_ESTADO_INICIAL VARCHAR(20);

    DECLARE V_TIENE_URL TINYINT DEFAULT 0;
    DECLARE V_TIENE_RUTA TINYINT DEFAULT 0;
    DECLARE V_TIENE_EVIDENCIA TINYINT DEFAULT 0;

    SET V_TIPO_ENTREGA =
        UPPER(TRIM(P_TIPO_ENTREGA));

    SET V_ESTADO_INICIAL =
        UPPER(
            TRIM(
                IFNULL(
                    P_ESTADO_INICIAL,
                    'REGISTRADA'
                )
            )
        );

    SET V_TIENE_URL =
        CASE
            WHEN P_EVIDENCIA_URL IS NOT NULL
             AND TRIM(P_EVIDENCIA_URL) <> ''
            THEN 1
            ELSE 0
        END;

    SET V_TIENE_RUTA =
        CASE
            WHEN P_EVIDENCIA_RUTA IS NOT NULL
             AND TRIM(P_EVIDENCIA_RUTA) <> ''
            THEN 1
            ELSE 0
        END;

    SET V_TIENE_EVIDENCIA =
        CASE
            WHEN V_TIENE_URL = 1
              OR V_TIENE_RUTA = 1
              OR (
                  P_EVIDENCIA_NOMBRE_ARCHIVO IS NOT NULL
                  AND TRIM(
                      P_EVIDENCIA_NOMBRE_ARCHIVO
                  ) <> ''
              )
            THEN 1
            ELSE 0
        END;

    SELECT COUNT(*)
    INTO V_EXISTE_EMPLEADO
    FROM bbf_empleados
    WHERE ID_EMPLEADO = P_ID_EMPLEADO
      AND ESTADO_EMPLEADO = 'ACTIVO'
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_EXISTE_EMPLEADO = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'El empleado no existe, esta inactivo o fue eliminado.';
    END IF;

    IF P_FECHA_ENTREGA IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'La fecha requerida o de entrega es obligatoria.';
    END IF;

    IF V_ESTADO_INICIAL NOT IN (
        'POR_COMPRAR',
        'REGISTRADA'
    ) THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'El estado inicial debe ser POR_COMPRAR o REGISTRADA.';
    END IF;

    IF V_TIPO_ENTREGA NOT IN (
        'ORDINARIA',
        'EXTRAORDINARIA'
    ) THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'El tipo de entrega debe ser ORDINARIA o EXTRAORDINARIA.';
    END IF;

    IF V_TIPO_ENTREGA = 'EXTRAORDINARIA'
       AND P_ID_DOTACION_COMBINACION IS NOT NULL THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'La entrega extraordinaria no debe tener una combinacion asociada.';
    END IF;

    IF V_TIPO_ENTREGA = 'ORDINARIA'
       AND P_ID_DOTACION_COMBINACION IS NOT NULL THEN

        SELECT COUNT(*)
        INTO V_EXISTE_COMBINACION
        FROM bbf_dotacion_combinaciones
        WHERE ID_DOTACION_COMBINACION =
              P_ID_DOTACION_COMBINACION
          AND ACTIVO = 1;

        IF V_EXISTE_COMBINACION = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'La combinacion seleccionada no existe o esta inactiva.';
        END IF;

        SELECT COUNT(*)
        INTO V_EXISTE_COMBINACION
        FROM bbf_dotacion_combinacion_detalle
        WHERE ID_DOTACION_COMBINACION =
              P_ID_DOTACION_COMBINACION
          AND ACTIVO = 1;

        IF V_EXISTE_COMBINACION = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'La combinacion seleccionada no contiene prendas activas.';
        END IF;
    END IF;

    IF V_ESTADO_INICIAL = 'POR_COMPRAR'
       AND V_TIENE_EVIDENCIA = 1 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Una solicitud por comprar no debe registrar evidencia de entrega.';
    END IF;

    IF V_ESTADO_INICIAL = 'REGISTRADA' THEN

        IF P_EVIDENCIA_NOMBRE_ARCHIVO IS NULL
           OR TRIM(
               P_EVIDENCIA_NOMBRE_ARCHIVO
           ) = '' THEN

            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'El nombre de la evidencia es obligatorio.';
        END IF;

        IF V_TIENE_URL = 0
           AND V_TIENE_RUTA = 0 THEN

            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Debe registrar una URL externa o cargar un archivo como evidencia.';
        END IF;

        IF V_TIENE_URL = 1
           AND V_TIENE_RUTA = 1 THEN

            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'La evidencia debe ser una URL externa o un archivo fisico, no ambos.';
        END IF;
    END IF;

    INSERT INTO bbf_dotacion_entregas
    (
        ID_EMPLEADO,
        FECHA_ENTREGA,
        TIPO_ENTREGA,
        ID_DOTACION_COMBINACION,
        ESTADO,
        OBSERVACIONES,
        ID_REGISTRADO_POR,

        EVIDENCIA_NOMBRE_ARCHIVO,
        EVIDENCIA_NOMBRE_ORIGINAL,
        EVIDENCIA_URL,
        EVIDENCIA_RUTA,
        EVIDENCIA_MIME_TYPE,
        EVIDENCIA_PESO_BYTES,
        EVIDENCIA_FECHA_CARGA
    )
    VALUES
    (
        P_ID_EMPLEADO,
        P_FECHA_ENTREGA,
        V_TIPO_ENTREGA,

        CASE
            WHEN V_TIPO_ENTREGA = 'ORDINARIA'
            THEN P_ID_DOTACION_COMBINACION
            ELSE NULL
        END,

        V_ESTADO_INICIAL,

        NULLIF(
            TRIM(P_OBSERVACIONES),
            ''
        ),

        P_ID_REGISTRADO_POR,

        CASE
            WHEN V_ESTADO_INICIAL = 'REGISTRADA'
            THEN NULLIF(
                TRIM(P_EVIDENCIA_NOMBRE_ARCHIVO),
                ''
            )
            ELSE NULL
        END,

        CASE
            WHEN V_ESTADO_INICIAL = 'REGISTRADA'
            THEN NULLIF(
                TRIM(P_EVIDENCIA_NOMBRE_ORIGINAL),
                ''
            )
            ELSE NULL
        END,

        CASE
            WHEN V_ESTADO_INICIAL = 'REGISTRADA'
            THEN NULLIF(
                TRIM(P_EVIDENCIA_URL),
                ''
            )
            ELSE NULL
        END,

        CASE
            WHEN V_ESTADO_INICIAL = 'REGISTRADA'
            THEN NULLIF(
                TRIM(P_EVIDENCIA_RUTA),
                ''
            )
            ELSE NULL
        END,

        CASE
            WHEN V_ESTADO_INICIAL = 'REGISTRADA'
            THEN P_EVIDENCIA_MIME_TYPE
            ELSE NULL
        END,

        CASE
            WHEN V_ESTADO_INICIAL = 'REGISTRADA'
            THEN P_EVIDENCIA_PESO_BYTES
            ELSE NULL
        END,

        CASE
            WHEN V_ESTADO_INICIAL = 'REGISTRADA'
            THEN CURRENT_TIMESTAMP
            ELSE NULL
        END
    );

    SET V_ID_DOTACION_ENTREGA =
        LAST_INSERT_ID();

    SELECT
        DE.ID_DOTACION_ENTREGA,
        DE.ID_EMPLEADO,
        DE.FECHA_ENTREGA,
        DE.TIPO_ENTREGA,

        DE.ID_DOTACION_COMBINACION,
        C.CODIGO AS CODIGO_COMBINACION,
        C.NOMBRE AS NOMBRE_COMBINACION,

        DE.ESTADO,
        DE.OBSERVACIONES,
        DE.ID_REGISTRADO_POR,

        DE.EVIDENCIA_NOMBRE_ARCHIVO,
        DE.EVIDENCIA_NOMBRE_ORIGINAL,
        DE.EVIDENCIA_URL,
        DE.EVIDENCIA_RUTA,
        DE.EVIDENCIA_MIME_TYPE,
        DE.EVIDENCIA_PESO_BYTES,
        DE.EVIDENCIA_FECHA_CARGA,

        DE.CREATED_AT

    FROM bbf_dotacion_entregas DE

    LEFT JOIN bbf_dotacion_combinaciones C
        ON C.ID_DOTACION_COMBINACION =
           DE.ID_DOTACION_COMBINACION

    WHERE DE.ID_DOTACION_ENTREGA =
          V_ID_DOTACION_ENTREGA;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_ENTREGA_DETALLE_AGREGAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DOTACION_ENTREGA_DETALLE_AGREGAR`(
        IN P_ID_DOTACION_ENTREGA INT,
        IN P_ID_TIPO_DOTACION INT,
        IN P_ID_TALLA_DOTACION INT,
        IN P_CANTIDAD INT,
        IN P_OBSERVACIONES VARCHAR(250)
    )
BEGIN
    DECLARE V_ID_DOTACION_ARTICULO INT DEFAULT NULL;
    DECLARE V_REQUIERE_TALLA TINYINT DEFAULT NULL;
    DECLARE V_ESTADO VARCHAR(20) DEFAULT NULL;
    DECLARE V_ELIMINADO TINYINT DEFAULT 0;

    SELECT
        ESTADO,
        ELIMINADO
    INTO
        V_ESTADO,
        V_ELIMINADO
    FROM bbf_dotacion_entregas
    WHERE ID_DOTACION_ENTREGA =
          P_ID_DOTACION_ENTREGA
    LIMIT 1;

    IF V_ESTADO IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'La entrega de dotacion no existe.';
    END IF;

    IF IFNULL(V_ELIMINADO, 0) = 1
       OR V_ESTADO NOT IN (
           'POR_COMPRAR',
           'REGISTRADA'
       ) THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Solo se pueden agregar elementos a entregas POR_COMPRAR o REGISTRADA.';
    END IF;

    SELECT
        REQUIERE_TALLA
    INTO
        V_REQUIERE_TALLA
    FROM bbf_tipos_dotacion
    WHERE ID_TIPO_DOTACION =
          P_ID_TIPO_DOTACION
      AND ACTIVO = 1
    LIMIT 1;

    IF V_REQUIERE_TALLA IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'El tipo de dotacion no existe o esta inactivo.';
    END IF;

    SELECT
        ID_DOTACION_ARTICULO
    INTO
        V_ID_DOTACION_ARTICULO
    FROM bbf_dotacion_articulos
    WHERE ID_TIPO_DOTACION =
          P_ID_TIPO_DOTACION
      AND ES_LEGACY = 1
    ORDER BY
        ID_DOTACION_ARTICULO ASC
    LIMIT 1;

    IF V_ID_DOTACION_ARTICULO IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'No existe el articulo legacy para el tipo de dotacion indicado.';
    END IF;

    IF IFNULL(P_CANTIDAD, 0) <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'La cantidad debe ser mayor que cero.';
    END IF;

    IF V_REQUIERE_TALLA = 1 THEN

        IF P_ID_TALLA_DOTACION IS NULL
           OR NOT EXISTS (
               SELECT 1
               FROM bbf_tallas_dotacion
               WHERE ID_TALLA_DOTACION =
                     P_ID_TALLA_DOTACION
                 AND ID_TIPO_DOTACION =
                     P_ID_TIPO_DOTACION
                 AND ACTIVO = 1
           ) THEN

            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Debe seleccionar una talla activa correspondiente al tipo de dotacion.';
        END IF;

    ELSEIF P_ID_TALLA_DOTACION IS NOT NULL THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'El tipo de dotacion seleccionado no utiliza talla.';
    END IF;

    INSERT INTO bbf_dotacion_entrega_detalle
    (
        ID_DOTACION_ENTREGA,
        ID_TIPO_DOTACION,
        ID_DOTACION_ARTICULO,
        ID_TALLA_DOTACION,
        CANTIDAD,
        OBSERVACIONES
    )
    VALUES
    (
        P_ID_DOTACION_ENTREGA,
        P_ID_TIPO_DOTACION,
        V_ID_DOTACION_ARTICULO,
        P_ID_TALLA_DOTACION,
        P_CANTIDAD,
        NULLIF(
            TRIM(P_OBSERVACIONES),
            ''
        )
    );

    SELECT
        LAST_INSERT_ID()
            AS ID_DOTACION_ENTREGA_DETALLE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_ENTREGA_DETALLE_AGREGAR_V2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DOTACION_ENTREGA_DETALLE_AGREGAR_V2`(
        IN P_ID_DOTACION_ENTREGA INT,
        IN P_ID_DOTACION_ARTICULO INT,
        IN P_ID_TIPO_DOTACION INT,
        IN P_ID_TALLA_DOTACION INT,
        IN P_CANTIDAD INT,
        IN P_OBSERVACIONES VARCHAR(250)
    )
BEGIN
    DECLARE V_ID_TIPO_ARTICULO INT DEFAULT NULL;
    DECLARE V_REQUIERE_TALLA TINYINT DEFAULT NULL;
    DECLARE V_ESTADO VARCHAR(20) DEFAULT NULL;
    DECLARE V_ELIMINADO TINYINT DEFAULT 0;
    DECLARE V_ID_DETALLE INT DEFAULT NULL;

    SELECT
        ESTADO,
        ELIMINADO
    INTO
        V_ESTADO,
        V_ELIMINADO
    FROM bbf_dotacion_entregas
    WHERE ID_DOTACION_ENTREGA =
          P_ID_DOTACION_ENTREGA
    LIMIT 1;

    IF V_ESTADO IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'La entrega de dotacion no existe.';
    END IF;

    IF IFNULL(V_ELIMINADO, 0) = 1
       OR V_ESTADO NOT IN (
           'POR_COMPRAR',
           'REGISTRADA'
       ) THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Solo se pueden agregar elementos a entregas POR_COMPRAR o REGISTRADA.';
    END IF;

    SELECT
        DA.ID_TIPO_DOTACION,
        TD.REQUIERE_TALLA
    INTO
        V_ID_TIPO_ARTICULO,
        V_REQUIERE_TALLA

    FROM bbf_dotacion_articulos DA

    INNER JOIN bbf_tipos_dotacion TD
        ON TD.ID_TIPO_DOTACION =
           DA.ID_TIPO_DOTACION

    WHERE DA.ID_DOTACION_ARTICULO =
          P_ID_DOTACION_ARTICULO

      AND DA.ACTIVO = 1
      AND DA.ES_LEGACY = 0
      AND TD.ACTIVO = 1

    LIMIT 1;

    IF V_ID_TIPO_ARTICULO IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'El articulo no existe, esta inactivo o es historico.';
    END IF;

    IF P_ID_TIPO_DOTACION IS NULL
       OR P_ID_TIPO_DOTACION <>
          V_ID_TIPO_ARTICULO THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'El articulo no pertenece al tipo de dotacion indicado.';
    END IF;

    IF IFNULL(P_CANTIDAD, 0) <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'La cantidad debe ser mayor que cero.';
    END IF;

    IF V_REQUIERE_TALLA = 1 THEN

        IF P_ID_TALLA_DOTACION IS NULL
           OR NOT EXISTS (
               SELECT 1
               FROM bbf_tallas_dotacion
               WHERE ID_TALLA_DOTACION =
                     P_ID_TALLA_DOTACION

                 AND ID_TIPO_DOTACION =
                     V_ID_TIPO_ARTICULO

                 AND ACTIVO = 1
           ) THEN

            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Debe seleccionar una talla activa correspondiente al articulo.';
        END IF;

    ELSEIF P_ID_TALLA_DOTACION IS NOT NULL THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'El articulo seleccionado no utiliza talla.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM bbf_dotacion_entrega_detalle
        WHERE ID_DOTACION_ENTREGA =
              P_ID_DOTACION_ENTREGA

          AND ID_DOTACION_ARTICULO =
              P_ID_DOTACION_ARTICULO

          AND ID_TALLA_DOTACION
              <=> P_ID_TALLA_DOTACION

          AND IFNULL(ELIMINADO, 0) = 0
    ) THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'El articulo y la talla ya fueron agregados a esta entrega.';
    END IF;

    INSERT INTO bbf_dotacion_entrega_detalle
    (
        ID_DOTACION_ENTREGA,
        ID_TIPO_DOTACION,
        ID_DOTACION_ARTICULO,
        ID_TALLA_DOTACION,
        CANTIDAD,
        OBSERVACIONES
    )
    VALUES
    (
        P_ID_DOTACION_ENTREGA,
        V_ID_TIPO_ARTICULO,
        P_ID_DOTACION_ARTICULO,
        P_ID_TALLA_DOTACION,
        P_CANTIDAD,
        NULLIF(
            TRIM(P_OBSERVACIONES),
            ''
        )
    );

    SET V_ID_DETALLE =
        LAST_INSERT_ID();

    SELECT
        DD.ID_DOTACION_ENTREGA_DETALLE,
        DD.ID_DOTACION_ENTREGA,

        DD.ID_DOTACION_ARTICULO,
        DA.CODIGO AS CODIGO_ARTICULO,
        DA.NOMBRE AS ARTICULO,
        DA.GENERO,
        DA.UNIDAD_MEDIDA,

        DD.ID_TIPO_DOTACION,
        TD.NOMBRE AS TIPO_DOTACION,

        DD.ID_TALLA_DOTACION,
        T.TALLA,

        DD.CANTIDAD,
        DD.OBSERVACIONES

    FROM bbf_dotacion_entrega_detalle DD

    INNER JOIN bbf_dotacion_articulos DA
        ON DA.ID_DOTACION_ARTICULO =
           DD.ID_DOTACION_ARTICULO

    INNER JOIN bbf_tipos_dotacion TD
        ON TD.ID_TIPO_DOTACION =
           DD.ID_TIPO_DOTACION

    LEFT JOIN bbf_tallas_dotacion T
        ON T.ID_TALLA_DOTACION =
           DD.ID_TALLA_DOTACION

    WHERE DD.ID_DOTACION_ENTREGA_DETALLE =
          V_ID_DETALLE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_ENTREGA_DETALLE_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DOTACION_ENTREGA_DETALLE_LISTAR`(
        IN P_ID_DOTACION_ENTREGA INT
    )
BEGIN
    SELECT
        DE.ID_DOTACION_ENTREGA,
        DE.ID_EMPLEADO,
        DE.FECHA_ENTREGA,
        DE.TIPO_ENTREGA,

        DE.ID_DOTACION_COMBINACION,
        C.CODIGO AS CODIGO_COMBINACION,
        C.NOMBRE AS NOMBRE_COMBINACION,

        DE.ESTADO,
        DE.OBSERVACIONES
            AS OBSERVACIONES_ENTREGA,

        DE.FECHA_CONFIRMACION,
        DE.OBSERVACION_CONFIRMACION,
        DE.FIRMA_URL,

        DE.EVIDENCIA_NOMBRE_ARCHIVO,
        DE.EVIDENCIA_NOMBRE_ORIGINAL,
        DE.EVIDENCIA_URL,
        DE.EVIDENCIA_RUTA,
        DE.EVIDENCIA_MIME_TYPE,
        DE.EVIDENCIA_PESO_BYTES,
        DE.EVIDENCIA_FECHA_CARGA,

        DD.ID_DOTACION_ENTREGA_DETALLE,

        DD.ID_DOTACION_ARTICULO,
        DA.CODIGO AS CODIGO_ARTICULO,

        COALESCE(
            DA.NOMBRE,
            TD.NOMBRE
        ) AS ARTICULO,

        DA.GENERO,
        DA.UNIDAD_MEDIDA,

        DD.ID_TIPO_DOTACION,
        TD.NOMBRE AS TIPO_DOTACION,
        TD.REQUIERE_TALLA,

        DD.ID_TALLA_DOTACION,
        T.TALLA,

        DD.CANTIDAD,
        DD.OBSERVACIONES,
        DD.CREATED_AT

    FROM bbf_dotacion_entrega_detalle DD

    INNER JOIN bbf_dotacion_entregas DE
        ON DE.ID_DOTACION_ENTREGA =
           DD.ID_DOTACION_ENTREGA

    INNER JOIN bbf_tipos_dotacion TD
        ON TD.ID_TIPO_DOTACION =
           DD.ID_TIPO_DOTACION

    LEFT JOIN bbf_dotacion_articulos DA
        ON DA.ID_DOTACION_ARTICULO =
           DD.ID_DOTACION_ARTICULO

    LEFT JOIN bbf_tallas_dotacion T
        ON T.ID_TALLA_DOTACION =
           DD.ID_TALLA_DOTACION

    LEFT JOIN bbf_dotacion_combinaciones C
        ON C.ID_DOTACION_COMBINACION =
           DE.ID_DOTACION_COMBINACION

    WHERE DD.ID_DOTACION_ENTREGA =
          P_ID_DOTACION_ENTREGA

      AND IFNULL(DE.ELIMINADO, 0) = 0
      AND IFNULL(DD.ELIMINADO, 0) = 0

    ORDER BY
        COALESCE(
            DA.NOMBRE,
            TD.NOMBRE
        ) ASC,

        T.ORDEN ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_ENTREGA_ELIMINAR_LOGICO` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DOTACION_ENTREGA_ELIMINAR_LOGICO`(
    IN P_ID_DOTACION_ENTREGA INT,
    IN P_ID_USUARIO INT,
    IN P_MOTIVO_ELIMINACION VARCHAR(500)
)
BEGIN
    DECLARE V_EXISTE INT DEFAULT 0;
    DECLARE V_ESTADO VARCHAR(50);

    SELECT COUNT(*)
    INTO V_EXISTE
    FROM bbf_dotacion_entregas
    WHERE ID_DOTACION_ENTREGA = P_ID_DOTACION_ENTREGA
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_EXISTE = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La entrega de dotación no existe o ya fue eliminada.';
    END IF;

    SELECT ESTADO
    INTO V_ESTADO
    FROM bbf_dotacion_entregas
    WHERE ID_DOTACION_ENTREGA = P_ID_DOTACION_ENTREGA
    LIMIT 1;

    IF V_ESTADO = 'ENTREGADA' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede eliminar una entrega ya confirmada por el empleado.';
    END IF;

    UPDATE bbf_dotacion_entregas
    SET
        ELIMINADO = 1,
        ESTADO = 'ANULADA',
        FECHA_ELIMINACION = CURRENT_TIMESTAMP,
        ID_ELIMINADO_POR = P_ID_USUARIO,
        MOTIVO_ELIMINACION = P_MOTIVO_ELIMINACION
    WHERE ID_DOTACION_ENTREGA = P_ID_DOTACION_ENTREGA;

    UPDATE bbf_dotacion_entrega_detalle
    SET
        ELIMINADO = 1,
        FECHA_ELIMINACION = CURRENT_TIMESTAMP,
        ID_ELIMINADO_POR = P_ID_USUARIO
    WHERE ID_DOTACION_ENTREGA = P_ID_DOTACION_ENTREGA;

    SELECT
        P_ID_DOTACION_ENTREGA AS ID_DOTACION_ENTREGA,
        1 AS ELIMINADO,
        'ANULADA' AS ESTADO,
        CURRENT_TIMESTAMP AS FECHA_ELIMINACION;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_HISTORIAL_EMPLEADO` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DOTACION_HISTORIAL_EMPLEADO`(
        IN P_ID_EMPLEADO INT
    )
BEGIN
    SELECT
        DE.ID_DOTACION_ENTREGA,
        DE.ID_EMPLEADO,

        E.NUMERO_DOCUMENTO,

        CONCAT(
            E.NOMBRES,
            ' ',
            E.APELLIDOS
        ) AS NOMBRE_COMPLETO,

        A.NOMBRE AS AREA,
        CARGO.NOMBRE AS CARGO,

        DE.FECHA_ENTREGA,
        DE.TIPO_ENTREGA,

        DE.ID_DOTACION_COMBINACION,
        COMB.CODIGO AS CODIGO_COMBINACION,
        COMB.NOMBRE AS NOMBRE_COMBINACION,

        DE.FECHA_CONFIRMACION,
        DE.ESTADO,

        DE.OBSERVACIONES
            AS OBSERVACIONES_ENTREGA,

        DE.OBSERVACION_CONFIRMACION,
        DE.FIRMA_URL,

        DE.EVIDENCIA_NOMBRE_ARCHIVO,
        DE.EVIDENCIA_NOMBRE_ORIGINAL,
        DE.EVIDENCIA_URL,
        DE.EVIDENCIA_RUTA,
        DE.EVIDENCIA_MIME_TYPE,
        DE.EVIDENCIA_PESO_BYTES,
        DE.EVIDENCIA_FECHA_CARGA,

        DE.ID_REGISTRADO_POR,
        UR.NOMBRE_USUARIO
            AS REGISTRADO_POR,

        DE.ID_CONFIRMADO_POR,
        UC.NOMBRE_USUARIO
            AS CONFIRMADO_POR,

        DD.ID_DOTACION_ENTREGA_DETALLE,

        DD.ID_DOTACION_ARTICULO,
        DA.CODIGO AS CODIGO_ARTICULO,

        COALESCE(
            DA.NOMBRE,
            TD.NOMBRE
        ) AS ARTICULO,

        DA.GENERO,
        DA.UNIDAD_MEDIDA,

        DD.ID_TIPO_DOTACION,
        TD.NOMBRE AS TIPO_DOTACION,

        DD.ID_TALLA_DOTACION,
        T.TALLA,

        DD.CANTIDAD,

        DD.OBSERVACIONES
            AS OBSERVACIONES_DETALLE,

        DE.CREATED_AT,
        DE.UPDATED_AT

    FROM bbf_dotacion_entregas DE

    INNER JOIN bbf_empleados E
        ON E.ID_EMPLEADO =
           DE.ID_EMPLEADO

    LEFT JOIN bbf_areas A
        ON A.ID_AREA =
           E.ID_AREA

    LEFT JOIN bbf_cargos CARGO
        ON CARGO.ID_CARGO =
           E.ID_CARGO

    LEFT JOIN bbf_usuarios UR
        ON UR.ID_USUARIO =
           DE.ID_REGISTRADO_POR

    LEFT JOIN bbf_usuarios UC
        ON UC.ID_USUARIO =
           DE.ID_CONFIRMADO_POR

    LEFT JOIN bbf_dotacion_combinaciones COMB
        ON COMB.ID_DOTACION_COMBINACION =
           DE.ID_DOTACION_COMBINACION

    INNER JOIN bbf_dotacion_entrega_detalle DD
        ON DD.ID_DOTACION_ENTREGA =
           DE.ID_DOTACION_ENTREGA

    INNER JOIN bbf_tipos_dotacion TD
        ON TD.ID_TIPO_DOTACION =
           DD.ID_TIPO_DOTACION

    LEFT JOIN bbf_dotacion_articulos DA
        ON DA.ID_DOTACION_ARTICULO =
           DD.ID_DOTACION_ARTICULO

    LEFT JOIN bbf_tallas_dotacion T
        ON T.ID_TALLA_DOTACION =
           DD.ID_TALLA_DOTACION

    WHERE DE.ID_EMPLEADO =
          P_ID_EMPLEADO

      AND IFNULL(DE.ELIMINADO, 0) = 0
      AND IFNULL(DD.ELIMINADO, 0) = 0

    ORDER BY
        DE.FECHA_ENTREGA DESC,
        DE.ID_DOTACION_ENTREGA DESC,

        COALESCE(
            DA.NOMBRE,
            TD.NOMBRE
        ) ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_MIS_ENTREGAS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DOTACION_MIS_ENTREGAS_LISTAR`(
    IN P_ID_USUARIO INT
)
BEGIN
    DECLARE V_ID_EMPLEADO INT;

    SELECT ID_EMPLEADO
    INTO V_ID_EMPLEADO
    FROM bbf_usuarios
    WHERE ID_USUARIO = P_ID_USUARIO
    LIMIT 1;

    IF V_ID_EMPLEADO IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'El usuario no tiene un empleado asociado.';
    END IF;

    SELECT
        DE.ID_DOTACION_ENTREGA,
        DE.ID_EMPLEADO,
        E.NUMERO_DOCUMENTO,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS)
            AS NOMBRE_COMPLETO,
        DE.FECHA_ENTREGA,
        DE.TIPO_ENTREGA,
        DE.ID_DOTACION_COMBINACION,
        C.CODIGO AS CODIGO_COMBINACION,
        C.NOMBRE AS NOMBRE_COMBINACION,
        DE.FECHA_CONFIRMACION,
        DE.ESTADO,
        DE.OBSERVACIONES,
        DE.OBSERVACION_CONFIRMACION,
        DE.FIRMA_URL,
        DE.EVIDENCIA_NOMBRE_ARCHIVO,
        DE.EVIDENCIA_NOMBRE_ORIGINAL,
        DE.EVIDENCIA_URL,
        DE.EVIDENCIA_RUTA,
        DE.EVIDENCIA_MIME_TYPE,
        DE.EVIDENCIA_PESO_BYTES,
        DE.EVIDENCIA_FECHA_CARGA,
        DE.ID_REGISTRADO_POR,
        UR.NOMBRE_USUARIO AS REGISTRADO_POR,
        DE.ID_CONFIRMADO_POR,
        UC.NOMBRE_USUARIO AS CONFIRMADO_POR,
        DE.CREATED_AT,
        DE.UPDATED_AT

    FROM bbf_dotacion_entregas DE

    INNER JOIN bbf_empleados E
        ON E.ID_EMPLEADO = DE.ID_EMPLEADO

    LEFT JOIN bbf_usuarios UR
        ON UR.ID_USUARIO = DE.ID_REGISTRADO_POR

    LEFT JOIN bbf_usuarios UC
        ON UC.ID_USUARIO = DE.ID_CONFIRMADO_POR

    LEFT JOIN bbf_dotacion_combinaciones C
        ON C.ID_DOTACION_COMBINACION =
           DE.ID_DOTACION_COMBINACION

    WHERE DE.ID_EMPLEADO = V_ID_EMPLEADO
      AND IFNULL(DE.ELIMINADO, 0) = 0
      AND DE.ESTADO IN ('REGISTRADA', 'ENTREGADA')

    ORDER BY
        DE.FECHA_ENTREGA DESC,
        DE.ID_DOTACION_ENTREGA DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_MIS_TALLAS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DOTACION_MIS_TALLAS_LISTAR`(
    IN P_ID_USUARIO INT
)
BEGIN
    DECLARE V_ID_EMPLEADO INT DEFAULT NULL;

    SELECT U.`ID_EMPLEADO`
      INTO V_ID_EMPLEADO
    FROM `bbf_usuarios` U
    INNER JOIN `bbf_empleados` E
        ON E.`ID_EMPLEADO` = U.`ID_EMPLEADO`
       AND IFNULL(E.`ELIMINADO`, 0) = 0
    WHERE U.`ID_USUARIO` = P_ID_USUARIO
    LIMIT 1;

    IF V_ID_EMPLEADO IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El usuario no tiene un empleado activo asociado.';
    END IF;

    SELECT
        V_ID_EMPLEADO AS `ID_EMPLEADO`,

        DA.`ID_DOTACION_ARTICULO`,
        DA.`CODIGO` AS `CODIGO_ARTICULO`,
        DA.`NOMBRE` AS `ARTICULO`,
        DA.`DESCRIPCION` AS `ARTICULO_DESCRIPCION`,
        DA.`GENERO`,
        DA.`UNIDAD_MEDIDA`,

        TD.`ID_TIPO_DOTACION`,
        TD.`NOMBRE` AS `TIPO_DOTACION`,
        TD.`DESCRIPCION` AS `TIPO_DOTACION_DESCRIPCION`,
        TD.`REQUIERE_TALLA`,

        EAT.`ID_EMPLEADO_DOTACION_ARTICULO_TALLA`,
        EDT.`ID_EMPLEADO_DOTACION_TALLA` AS `ID_TALLA_FAMILIA_LEGACY`,

        COALESCE(
            EAT.`ID_TALLA_DOTACION`,
            EDT.`ID_TALLA_DOTACION`
        ) AS `ID_TALLA_DOTACION`,

        COALESCE(
            TA.`TALLA`,
            TF.`TALLA`
        ) AS `TALLA`,

        COALESCE(
            TA.`DESCRIPCION`,
            TF.`DESCRIPCION`
        ) AS `TALLA_DESCRIPCION`,

        CASE
            WHEN EAT.`ID_TALLA_DOTACION` IS NOT NULL THEN 'ESPECIFICA'
            WHEN EDT.`ID_TALLA_DOTACION` IS NOT NULL THEN 'HEREDADA_FAMILIA'
            ELSE 'SIN_REGISTRAR'
        END AS `ORIGEN_TALLA`,

        CASE
            WHEN EAT.`ID_TALLA_DOTACION` IS NOT NULL THEN 0
            WHEN EDT.`ID_TALLA_DOTACION` IS NOT NULL THEN 1
            ELSE 0
        END AS `REQUIERE_CONFIRMACION`,

        COALESCE(
            EAT.`OBSERVACIONES`,
            EDT.`OBSERVACIONES`
        ) AS `OBSERVACIONES`,

        EAT.`CREATED_AT`,
        EAT.`UPDATED_AT`

    FROM `bbf_dotacion_articulos` DA

    INNER JOIN `bbf_tipos_dotacion` TD
        ON TD.`ID_TIPO_DOTACION` = DA.`ID_TIPO_DOTACION`
       AND TD.`ACTIVO` = 1
       AND TD.`REQUIERE_TALLA` = 1

    LEFT JOIN `bbf_empleado_dotacion_articulo_tallas` EAT
        ON EAT.`ID_EMPLEADO` = V_ID_EMPLEADO
       AND EAT.`ID_DOTACION_ARTICULO` = DA.`ID_DOTACION_ARTICULO`

    LEFT JOIN `bbf_tallas_dotacion` TA
        ON TA.`ID_TALLA_DOTACION` = EAT.`ID_TALLA_DOTACION`
       AND TA.`ID_TIPO_DOTACION` = DA.`ID_TIPO_DOTACION`

    LEFT JOIN `bbf_empleado_dotacion_tallas` EDT
        ON EDT.`ID_EMPLEADO` = V_ID_EMPLEADO
       AND EDT.`ID_TIPO_DOTACION` = DA.`ID_TIPO_DOTACION`

    LEFT JOIN `bbf_tallas_dotacion` TF
        ON TF.`ID_TALLA_DOTACION` = EDT.`ID_TALLA_DOTACION`
       AND TF.`ID_TIPO_DOTACION` = DA.`ID_TIPO_DOTACION`

    WHERE DA.`ACTIVO` = 1
      AND DA.`ES_LEGACY` = 0

    ORDER BY
        TD.`NOMBRE` ASC,
        DA.`NOMBRE` ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_MI_TALLA_ARTICULO_GUARDAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DOTACION_MI_TALLA_ARTICULO_GUARDAR`(
    IN P_ID_USUARIO INT,
    IN P_ID_DOTACION_ARTICULO INT,
    IN P_ID_TALLA_DOTACION INT,
    IN P_OBSERVACIONES VARCHAR(250)
)
BEGIN
    DECLARE V_ID_EMPLEADO INT DEFAULT NULL;
    DECLARE V_ID_TIPO_DOTACION INT DEFAULT NULL;

    SELECT U.`ID_EMPLEADO`
      INTO V_ID_EMPLEADO
    FROM `bbf_usuarios` U
    INNER JOIN `bbf_empleados` E
        ON E.`ID_EMPLEADO` = U.`ID_EMPLEADO`
       AND IFNULL(E.`ELIMINADO`, 0) = 0
    WHERE U.`ID_USUARIO` = P_ID_USUARIO
    LIMIT 1;

    IF V_ID_EMPLEADO IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El usuario no tiene un empleado activo asociado.';
    END IF;

    SELECT DA.`ID_TIPO_DOTACION`
      INTO V_ID_TIPO_DOTACION
    FROM `bbf_dotacion_articulos` DA
    INNER JOIN `bbf_tipos_dotacion` TD
        ON TD.`ID_TIPO_DOTACION` = DA.`ID_TIPO_DOTACION`
    WHERE DA.`ID_DOTACION_ARTICULO` = P_ID_DOTACION_ARTICULO
      AND DA.`ACTIVO` = 1
      AND DA.`ES_LEGACY` = 0
      AND TD.`ACTIVO` = 1
      AND TD.`REQUIERE_TALLA` = 1
    LIMIT 1;

    IF V_ID_TIPO_DOTACION IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El articulo no existe, esta inactivo, es historico o no utiliza talla.';
    END IF;

    IF P_ID_TALLA_DOTACION IS NULL OR NOT EXISTS (
        SELECT 1
        FROM `bbf_tallas_dotacion` T
        WHERE T.`ID_TALLA_DOTACION` = P_ID_TALLA_DOTACION
          AND T.`ID_TIPO_DOTACION` = V_ID_TIPO_DOTACION
          AND T.`ACTIVO` = 1
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La talla no esta activa o no pertenece a la familia del articulo.';
    END IF;

    INSERT INTO `bbf_empleado_dotacion_articulo_tallas` (
        `ID_EMPLEADO`,
        `ID_DOTACION_ARTICULO`,
        `ID_TIPO_DOTACION`,
        `ID_TALLA_DOTACION`,
        `OBSERVACIONES`,
        `ACTUALIZADO_POR_USUARIO`
    ) VALUES (
        V_ID_EMPLEADO,
        P_ID_DOTACION_ARTICULO,
        V_ID_TIPO_DOTACION,
        P_ID_TALLA_DOTACION,
        NULLIF(TRIM(P_OBSERVACIONES), ''),
        P_ID_USUARIO
    )
    ON DUPLICATE KEY UPDATE
        `ID_TIPO_DOTACION` = VALUES(`ID_TIPO_DOTACION`),
        `ID_TALLA_DOTACION` = VALUES(`ID_TALLA_DOTACION`),
        `OBSERVACIONES` = VALUES(`OBSERVACIONES`),
        `ACTUALIZADO_POR_USUARIO` = VALUES(`ACTUALIZADO_POR_USUARIO`),
        `UPDATED_AT` = CURRENT_TIMESTAMP;

    SELECT
        EAT.`ID_EMPLEADO_DOTACION_ARTICULO_TALLA`,
        EAT.`ID_EMPLEADO`,
        EAT.`ID_DOTACION_ARTICULO`,
        DA.`CODIGO` AS `CODIGO_ARTICULO`,
        DA.`NOMBRE` AS `ARTICULO`,
        DA.`GENERO`,
        DA.`UNIDAD_MEDIDA`,
        EAT.`ID_TIPO_DOTACION`,
        TD.`NOMBRE` AS `TIPO_DOTACION`,
        TD.`REQUIERE_TALLA`,
        EAT.`ID_TALLA_DOTACION`,
        T.`TALLA`,
        T.`DESCRIPCION` AS `TALLA_DESCRIPCION`,
        'ESPECIFICA' AS `ORIGEN_TALLA`,
        0 AS `REQUIERE_CONFIRMACION`,
        EAT.`OBSERVACIONES`,
        EAT.`CREATED_AT`,
        EAT.`UPDATED_AT`
    FROM `bbf_empleado_dotacion_articulo_tallas` EAT
    INNER JOIN `bbf_dotacion_articulos` DA
        ON DA.`ID_DOTACION_ARTICULO` = EAT.`ID_DOTACION_ARTICULO`
    INNER JOIN `bbf_tipos_dotacion` TD
        ON TD.`ID_TIPO_DOTACION` = EAT.`ID_TIPO_DOTACION`
    INNER JOIN `bbf_tallas_dotacion` T
        ON T.`ID_TALLA_DOTACION` = EAT.`ID_TALLA_DOTACION`
       AND T.`ID_TIPO_DOTACION` = EAT.`ID_TIPO_DOTACION`
    WHERE EAT.`ID_EMPLEADO` = V_ID_EMPLEADO
      AND EAT.`ID_DOTACION_ARTICULO` = P_ID_DOTACION_ARTICULO;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_MI_TALLA_GUARDAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DOTACION_MI_TALLA_GUARDAR`(
    IN P_ID_USUARIO INT,
    IN P_ID_TIPO_DOTACION INT,
    IN P_ID_TALLA_DOTACION INT,
    IN P_OBSERVACIONES VARCHAR(250)
)
BEGIN
    DECLARE V_ID_EMPLEADO INT;
    DECLARE V_EXISTE_TIPO INT DEFAULT 0;
    DECLARE V_EXISTE_TALLA INT DEFAULT 0;

    SELECT ID_EMPLEADO
    INTO V_ID_EMPLEADO
    FROM bbf_usuarios
    WHERE ID_USUARIO = P_ID_USUARIO
    LIMIT 1;

    IF V_ID_EMPLEADO IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El usuario no tiene un empleado asociado.';
    END IF;

    SELECT COUNT(*)
    INTO V_EXISTE_TIPO
    FROM bbf_tipos_dotacion
    WHERE ID_TIPO_DOTACION = P_ID_TIPO_DOTACION
      AND ACTIVO = 1;

    IF V_EXISTE_TIPO = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El tipo de dotación no existe o está inactivo.';
    END IF;

    IF P_ID_TALLA_DOTACION IS NOT NULL THEN
        SELECT COUNT(*)
        INTO V_EXISTE_TALLA
        FROM bbf_tallas_dotacion
        WHERE ID_TALLA_DOTACION = P_ID_TALLA_DOTACION
          AND ID_TIPO_DOTACION = P_ID_TIPO_DOTACION
          AND ACTIVO = 1;

        IF V_EXISTE_TALLA = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La talla no corresponde al tipo de dotación indicado.';
        END IF;
    END IF;

    INSERT INTO bbf_empleado_dotacion_tallas (
        ID_EMPLEADO,
        ID_TIPO_DOTACION,
        ID_TALLA_DOTACION,
        OBSERVACIONES,
        ACTUALIZADO_POR_USUARIO
    )
    VALUES (
        V_ID_EMPLEADO,
        P_ID_TIPO_DOTACION,
        P_ID_TALLA_DOTACION,
        P_OBSERVACIONES,
        P_ID_USUARIO
    )
    ON DUPLICATE KEY UPDATE
        ID_TALLA_DOTACION = VALUES(ID_TALLA_DOTACION),
        OBSERVACIONES = VALUES(OBSERVACIONES),
        ACTUALIZADO_POR_USUARIO = VALUES(ACTUALIZADO_POR_USUARIO),
        UPDATED_AT = CURRENT_TIMESTAMP;

    SELECT
        EDT.ID_EMPLEADO_DOTACION_TALLA,
        EDT.ID_EMPLEADO,
        EDT.ID_TIPO_DOTACION,
        TD.NOMBRE AS TIPO_DOTACION,
        EDT.ID_TALLA_DOTACION,
        T.TALLA,
        EDT.OBSERVACIONES,
        EDT.CREATED_AT,
        EDT.UPDATED_AT
    FROM bbf_empleado_dotacion_tallas EDT
    INNER JOIN bbf_tipos_dotacion TD
        ON TD.ID_TIPO_DOTACION = EDT.ID_TIPO_DOTACION
    LEFT JOIN bbf_tallas_dotacion T
        ON T.ID_TALLA_DOTACION = EDT.ID_TALLA_DOTACION
    WHERE EDT.ID_EMPLEADO = V_ID_EMPLEADO
      AND EDT.ID_TIPO_DOTACION = P_ID_TIPO_DOTACION;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_POR_COMPRAR_PREPARAR_ENTREGA` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DOTACION_POR_COMPRAR_PREPARAR_ENTREGA`(
        IN P_ID_DOTACION_ENTREGA INT,
        IN P_FECHA_ENTREGA DATE,
        IN P_ID_USUARIO INT,

        IN P_EVIDENCIA_NOMBRE_ARCHIVO VARCHAR(255),
        IN P_EVIDENCIA_NOMBRE_ORIGINAL VARCHAR(255),
        IN P_EVIDENCIA_URL VARCHAR(500),
        IN P_EVIDENCIA_RUTA VARCHAR(500),
        IN P_EVIDENCIA_MIME_TYPE VARCHAR(100),
        IN P_EVIDENCIA_PESO_BYTES BIGINT
    )
BEGIN
    DECLARE V_ESTADO VARCHAR(20);
    DECLARE V_ELIMINADO TINYINT DEFAULT 0;

    DECLARE V_TIENE_URL TINYINT DEFAULT 0;
    DECLARE V_TIENE_RUTA TINYINT DEFAULT 0;

    DECLARE V_TOTAL_DETALLES INT DEFAULT 0;
    DECLARE V_DETALLES_SIN_ARTICULO INT DEFAULT 0;

    SELECT
        ESTADO,
        ELIMINADO
    INTO
        V_ESTADO,
        V_ELIMINADO
    FROM bbf_dotacion_entregas
    WHERE ID_DOTACION_ENTREGA =
          P_ID_DOTACION_ENTREGA
    LIMIT 1;

    IF V_ESTADO IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'La solicitud de dotacion no existe.';
    END IF;

    IF IFNULL(V_ELIMINADO, 0) = 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'La solicitud fue eliminada o anulada.';
    END IF;

    IF V_ESTADO <> 'POR_COMPRAR' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Solo las solicitudes POR_COMPRAR pueden prepararse para entrega.';
    END IF;

    IF P_FECHA_ENTREGA IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'La fecha real de entrega es obligatoria.';
    END IF;

    IF P_ID_USUARIO IS NULL
       OR P_ID_USUARIO <= 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'El usuario que prepara la entrega es obligatorio.';
    END IF;

    SELECT
        COUNT(*),

        SUM(
            CASE
                WHEN ID_DOTACION_ARTICULO IS NULL
                THEN 1
                ELSE 0
            END
        )
    INTO
        V_TOTAL_DETALLES,
        V_DETALLES_SIN_ARTICULO

    FROM bbf_dotacion_entrega_detalle

    WHERE ID_DOTACION_ENTREGA =
          P_ID_DOTACION_ENTREGA

      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_TOTAL_DETALLES = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'La solicitud no contiene articulos para preparar la entrega.';
    END IF;

    IF IFNULL(
        V_DETALLES_SIN_ARTICULO,
        0
    ) > 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'La solicitud contiene detalles sin articulo de dotacion asociado.';
    END IF;

    SET V_TIENE_URL =
        CASE
            WHEN P_EVIDENCIA_URL IS NOT NULL
             AND TRIM(P_EVIDENCIA_URL) <> ''
            THEN 1
            ELSE 0
        END;

    SET V_TIENE_RUTA =
        CASE
            WHEN P_EVIDENCIA_RUTA IS NOT NULL
             AND TRIM(P_EVIDENCIA_RUTA) <> ''
            THEN 1
            ELSE 0
        END;

    IF P_EVIDENCIA_NOMBRE_ARCHIVO IS NULL
       OR TRIM(
           P_EVIDENCIA_NOMBRE_ARCHIVO
       ) = '' THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'El nombre de la evidencia es obligatorio.';
    END IF;

    IF V_TIENE_URL = 0
       AND V_TIENE_RUTA = 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Debe registrar una URL externa o cargar un archivo como evidencia.';
    END IF;

    IF V_TIENE_URL = 1
       AND V_TIENE_RUTA = 1 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'La evidencia debe ser una URL externa o un archivo fisico, no ambos.';
    END IF;

    UPDATE bbf_dotacion_entregas
    SET
        FECHA_ENTREGA =
            P_FECHA_ENTREGA,

        ESTADO =
            'REGISTRADA',

        EVIDENCIA_NOMBRE_ARCHIVO =
            NULLIF(
                TRIM(P_EVIDENCIA_NOMBRE_ARCHIVO),
                ''
            ),

        EVIDENCIA_NOMBRE_ORIGINAL =
            NULLIF(
                TRIM(P_EVIDENCIA_NOMBRE_ORIGINAL),
                ''
            ),

        EVIDENCIA_URL =
            NULLIF(
                TRIM(P_EVIDENCIA_URL),
                ''
            ),

        EVIDENCIA_RUTA =
            NULLIF(
                TRIM(P_EVIDENCIA_RUTA),
                ''
            ),

        EVIDENCIA_MIME_TYPE =
            P_EVIDENCIA_MIME_TYPE,

        EVIDENCIA_PESO_BYTES =
            P_EVIDENCIA_PESO_BYTES,

        EVIDENCIA_FECHA_CARGA =
            CURRENT_TIMESTAMP,

        UPDATED_AT =
            CURRENT_TIMESTAMP

    WHERE ID_DOTACION_ENTREGA =
          P_ID_DOTACION_ENTREGA

      AND ESTADO = 'POR_COMPRAR'
      AND IFNULL(ELIMINADO, 0) = 0;

    SELECT
        DE.ID_DOTACION_ENTREGA,
        DE.ID_EMPLEADO,
        DE.FECHA_ENTREGA,
        DE.TIPO_ENTREGA,
        DE.ID_DOTACION_COMBINACION,
        DE.ESTADO,
        DE.OBSERVACIONES,

        DE.EVIDENCIA_NOMBRE_ARCHIVO,
        DE.EVIDENCIA_NOMBRE_ORIGINAL,
        DE.EVIDENCIA_URL,
        DE.EVIDENCIA_RUTA,
        DE.EVIDENCIA_MIME_TYPE,
        DE.EVIDENCIA_PESO_BYTES,
        DE.EVIDENCIA_FECHA_CARGA,

        DE.ID_REGISTRADO_POR,
        DE.CREATED_AT,
        DE.UPDATED_AT

    FROM bbf_dotacion_entregas DE

    WHERE DE.ID_DOTACION_ENTREGA =
          P_ID_DOTACION_ENTREGA;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_TALLAS_EMPLEADO_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DOTACION_TALLAS_EMPLEADO_LISTAR`(
    IN P_ID_EMPLEADO INT
)
BEGIN
    SELECT
        E.ID_EMPLEADO,
        E.NUMERO_DOCUMENTO,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS) AS NOMBRE_COMPLETO,
        TD.ID_TIPO_DOTACION,
        TD.NOMBRE AS TIPO_DOTACION,
        EDT.ID_EMPLEADO_DOTACION_TALLA,
        EDT.ID_TALLA_DOTACION,
        T.TALLA,
        EDT.OBSERVACIONES,
        EDT.CREATED_AT,
        EDT.UPDATED_AT
    FROM bbf_tipos_dotacion TD
    CROSS JOIN bbf_empleados E
    LEFT JOIN bbf_empleado_dotacion_tallas EDT
        ON EDT.ID_TIPO_DOTACION = TD.ID_TIPO_DOTACION
       AND EDT.ID_EMPLEADO = E.ID_EMPLEADO
    LEFT JOIN bbf_tallas_dotacion T
        ON T.ID_TALLA_DOTACION = EDT.ID_TALLA_DOTACION
    WHERE E.ID_EMPLEADO = P_ID_EMPLEADO
      AND TD.ACTIVO = 1
    ORDER BY TD.NOMBRE ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_TALLAS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DOTACION_TALLAS_LISTAR`(
    IN P_ID_TIPO_DOTACION INT,
    IN P_SOLO_ACTIVOS TINYINT
)
BEGIN
    SELECT
        ID_TALLA_DOTACION,
        ID_TIPO_DOTACION,
        TALLA,
        DESCRIPCION,
        ORDEN,
        ACTIVO,
        CREATED_AT,
        UPDATED_AT
    FROM bbf_tallas_dotacion
    WHERE
        (P_ID_TIPO_DOTACION IS NULL OR P_ID_TIPO_DOTACION = 0 OR ID_TIPO_DOTACION = P_ID_TIPO_DOTACION)
        AND (P_SOLO_ACTIVOS = 0 OR ACTIVO = 1)
    ORDER BY ID_TIPO_DOTACION ASC, ORDEN ASC, TALLA ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_TIPOS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_DOTACION_TIPOS_LISTAR`(
    IN P_SOLO_ACTIVOS TINYINT
)
BEGIN
    SELECT
        ID_TIPO_DOTACION,
        NOMBRE,
        DESCRIPCION,
        REQUIERE_TALLA,
        ACTIVO,
        CREATED_AT,
        UPDATED_AT
    FROM bbf_tipos_dotacion
    WHERE P_SOLO_ACTIVOS = 0 OR ACTIVO = 1
    ORDER BY NOMBRE ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_EMPLEADOS_ACTUALIZAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_EMPLEADOS_ACTUALIZAR`(
    IN P_ID_EMPLEADO INT,
    IN P_ID_TIPO_DOCUMENTO INT,
    IN P_NUMERO_DOCUMENTO VARCHAR(50),
    IN P_NOMBRES VARCHAR(150),
    IN P_APELLIDOS VARCHAR(150),
    IN P_CORREO VARCHAR(150),
    IN P_TELEFONO VARCHAR(50),
    IN P_FOTO_URL VARCHAR(500),
    IN P_ID_AREA INT,
    IN P_ID_CARGO INT,
    IN P_ID_TIPO_CONTRATO INT,
    IN P_FECHA_INGRESO DATE,
    IN P_FECHA_RETIRO DATE,
    IN P_ESTADO_EMPLEADO VARCHAR(50),
    IN P_OBSERVACIONES TEXT
)
BEGIN
    UPDATE bbf_empleados
    SET
        ID_TIPO_DOCUMENTO = P_ID_TIPO_DOCUMENTO,
        NUMERO_DOCUMENTO = P_NUMERO_DOCUMENTO,
        NOMBRES = P_NOMBRES,
        APELLIDOS = P_APELLIDOS,
        CORREO = P_CORREO,
        TELEFONO = P_TELEFONO,
        FOTO_URL = P_FOTO_URL,
        ID_AREA = P_ID_AREA,
        ID_CARGO = P_ID_CARGO,
        ID_TIPO_CONTRATO = P_ID_TIPO_CONTRATO,
        FECHA_INGRESO = P_FECHA_INGRESO,
        FECHA_RETIRO = P_FECHA_RETIRO,
        ESTADO_EMPLEADO = P_ESTADO_EMPLEADO,
        OBSERVACIONES = P_OBSERVACIONES
    WHERE ID_EMPLEADO = P_ID_EMPLEADO;

    SELECT ROW_COUNT() AS FILAS_AFECTADAS;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_EMPLEADOS_CAMBIAR_ESTADO` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_EMPLEADOS_CAMBIAR_ESTADO`(
    IN P_ID_EMPLEADO INT,
    IN P_ESTADO_EMPLEADO VARCHAR(50),
    IN P_FECHA_RETIRO DATE
)
BEGIN
    UPDATE bbf_empleados
    SET
        ESTADO_EMPLEADO = P_ESTADO_EMPLEADO,
        FECHA_RETIRO = CASE
            WHEN P_ESTADO_EMPLEADO = 'RETIRADO' THEN IFNULL(P_FECHA_RETIRO, CURRENT_DATE)
            WHEN P_ESTADO_EMPLEADO = 'EN_PROCESO_RETIRO' THEN P_FECHA_RETIRO
            ELSE NULL
        END,
        UPDATED_AT = CURRENT_TIMESTAMP
    WHERE
        ID_EMPLEADO = P_ID_EMPLEADO
        AND ELIMINADO = 0
        AND P_ESTADO_EMPLEADO IN (
            'ACTIVO',
            'RETIRADO',
            'SUSPENDIDO',
            'INCAPACITADO',
            'EN_PROCESO_RETIRO'
        );

    SELECT ROW_COUNT() AS FILAS_AFECTADAS;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_EMPLEADOS_CREAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_EMPLEADOS_CREAR`(
    IN P_ID_TIPO_DOCUMENTO INT,
    IN P_NUMERO_DOCUMENTO VARCHAR(50),
    IN P_NOMBRES VARCHAR(150),
    IN P_APELLIDOS VARCHAR(150),
    IN P_CORREO VARCHAR(150),
    IN P_TELEFONO VARCHAR(50),
    IN P_FOTO_URL VARCHAR(500),
    IN P_ID_AREA INT,
    IN P_ID_CARGO INT,
    IN P_ID_TIPO_CONTRATO INT,
    IN P_FECHA_INGRESO DATE,
    IN P_FECHA_RETIRO DATE,
    IN P_ESTADO_EMPLEADO VARCHAR(50),
    IN P_OBSERVACIONES TEXT
)
BEGIN
    INSERT INTO bbf_empleados (
        ID_TIPO_DOCUMENTO,
        NUMERO_DOCUMENTO,
        NOMBRES,
        APELLIDOS,
        CORREO,
        TELEFONO,
        FOTO_URL,
        ID_AREA,
        ID_CARGO,
        ID_TIPO_CONTRATO,
        FECHA_INGRESO,
        FECHA_RETIRO,
        ESTADO_EMPLEADO,
        OBSERVACIONES
    )
    VALUES (
        P_ID_TIPO_DOCUMENTO,
        P_NUMERO_DOCUMENTO,
        P_NOMBRES,
        P_APELLIDOS,
        P_CORREO,
        P_TELEFONO,
        P_FOTO_URL,
        P_ID_AREA,
        P_ID_CARGO,
        P_ID_TIPO_CONTRATO,
        P_FECHA_INGRESO,
        P_FECHA_RETIRO,
        IFNULL(P_ESTADO_EMPLEADO, 'ACTIVO'),
        P_OBSERVACIONES
    );

    SELECT LAST_INSERT_ID() AS ID_EMPLEADO;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_EMPLEADOS_ELIMINAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_EMPLEADOS_ELIMINAR`(
    IN P_ID_EMPLEADO INT
)
BEGIN
    UPDATE bbf_empleados
    SET
        ELIMINADO = 1,
        FECHA_ELIMINACION = CURRENT_TIMESTAMP,
        UPDATED_AT = CURRENT_TIMESTAMP
    WHERE
        ID_EMPLEADO = P_ID_EMPLEADO
        AND ELIMINADO = 0;

    SELECT ROW_COUNT() AS FILAS_AFECTADAS;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_EMPLEADOS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_EMPLEADOS_LISTAR`(
    IN P_ESTADO_EMPLEADO VARCHAR(50),
    IN P_ID_AREA INT,
    IN P_ID_CARGO INT,
    IN P_TEXTO_BUSQUEDA VARCHAR(150)
)
BEGIN
    SELECT
        E.ID_EMPLEADO,
        E.ID_TIPO_DOCUMENTO,
        TD.NOMBRE AS TIPO_DOCUMENTO,
        E.NUMERO_DOCUMENTO,
        E.NOMBRES,
        E.APELLIDOS,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS) AS NOMBRE_COMPLETO,
        E.CORREO,
        E.TELEFONO,
        E.FOTO_URL,
        E.ID_AREA,
        A.NOMBRE AS AREA,
        E.ID_CARGO,
        C.NOMBRE AS CARGO,
        E.ID_TIPO_CONTRATO,
        TC.NOMBRE AS TIPO_CONTRATO,
        E.FECHA_INGRESO,
        E.FECHA_RETIRO,
        E.ESTADO_EMPLEADO,
        E.OBSERVACIONES,
        E.CREATED_AT,
        E.UPDATED_AT
    FROM bbf_empleados E
    LEFT JOIN bbf_tipos_documento TD
        ON TD.ID_TIPO_DOCUMENTO = E.ID_TIPO_DOCUMENTO
    LEFT JOIN bbf_areas A
        ON A.ID_AREA = E.ID_AREA
    LEFT JOIN bbf_cargos C
        ON C.ID_CARGO = E.ID_CARGO
    LEFT JOIN bbf_tipos_contrato TC
        ON TC.ID_TIPO_CONTRATO = E.ID_TIPO_CONTRATO
    WHERE
        IFNULL(E.ELIMINADO, 0) = 0
        AND (P_ESTADO_EMPLEADO IS NULL OR P_ESTADO_EMPLEADO = '' OR E.ESTADO_EMPLEADO = P_ESTADO_EMPLEADO)
        AND (P_ID_AREA IS NULL OR P_ID_AREA = 0 OR E.ID_AREA = P_ID_AREA)
        AND (P_ID_CARGO IS NULL OR P_ID_CARGO = 0 OR E.ID_CARGO = P_ID_CARGO)
        AND (
            P_TEXTO_BUSQUEDA IS NULL
            OR P_TEXTO_BUSQUEDA = ''
            OR E.NUMERO_DOCUMENTO LIKE CONCAT('%', P_TEXTO_BUSQUEDA, '%')
            OR E.NOMBRES LIKE CONCAT('%', P_TEXTO_BUSQUEDA, '%')
            OR E.APELLIDOS LIKE CONCAT('%', P_TEXTO_BUSQUEDA, '%')
            OR E.CORREO LIKE CONCAT('%', P_TEXTO_BUSQUEDA, '%')
        )
    ORDER BY E.CREATED_AT DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_EMPLEADOS_OBTENER_POR_DOCUMENTO` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_EMPLEADOS_OBTENER_POR_DOCUMENTO`(
    IN P_NUMERO_DOCUMENTO VARCHAR(50)
)
BEGIN
    SELECT
        E.ID_EMPLEADO,
        E.ID_TIPO_DOCUMENTO,
        TD.NOMBRE AS TIPO_DOCUMENTO,
        E.NUMERO_DOCUMENTO,
        E.NOMBRES,
        E.APELLIDOS,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS) AS NOMBRE_COMPLETO,
        E.CORREO,
        E.TELEFONO,
        E.FOTO_URL,
        E.ID_AREA,
        A.NOMBRE AS AREA,
        E.ID_CARGO,
        C.NOMBRE AS CARGO,
        E.ID_TIPO_CONTRATO,
        TC.NOMBRE AS TIPO_CONTRATO,
        E.ESTADO_EMPLEADO,
        E.FECHA_INGRESO,
        E.FECHA_RETIRO,
        E.OBSERVACIONES
    FROM bbf_empleados E
    LEFT JOIN bbf_tipos_documento TD
        ON TD.ID_TIPO_DOCUMENTO = E.ID_TIPO_DOCUMENTO
    LEFT JOIN bbf_areas A
        ON A.ID_AREA = E.ID_AREA
    LEFT JOIN bbf_cargos C
        ON C.ID_CARGO = E.ID_CARGO
    LEFT JOIN bbf_tipos_contrato TC
        ON TC.ID_TIPO_CONTRATO = E.ID_TIPO_CONTRATO
    WHERE E.NUMERO_DOCUMENTO = P_NUMERO_DOCUMENTO
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_EMPLEADOS_OBTENER_POR_ID` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_EMPLEADOS_OBTENER_POR_ID`(
    IN P_ID_EMPLEADO INT
)
BEGIN
    SELECT
        E.ID_EMPLEADO,
        E.ID_TIPO_DOCUMENTO,
        TD.NOMBRE AS TIPO_DOCUMENTO,
        E.NUMERO_DOCUMENTO,
        E.NOMBRES,
        E.APELLIDOS,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS) AS NOMBRE_COMPLETO,
        E.CORREO,
        E.TELEFONO,
        E.FOTO_URL,
        E.ID_AREA,
        A.NOMBRE AS AREA,
        E.ID_CARGO,
        C.NOMBRE AS CARGO,
        E.ID_TIPO_CONTRATO,
        TC.NOMBRE AS TIPO_CONTRATO,
        E.FECHA_INGRESO,
        E.FECHA_RETIRO,
        E.ESTADO_EMPLEADO,
        E.OBSERVACIONES,
        E.CREATED_AT,
        E.UPDATED_AT
    FROM bbf_empleados E
    LEFT JOIN bbf_tipos_documento TD
        ON TD.ID_TIPO_DOCUMENTO = E.ID_TIPO_DOCUMENTO
    LEFT JOIN bbf_areas A
        ON A.ID_AREA = E.ID_AREA
    LEFT JOIN bbf_cargos C
        ON C.ID_CARGO = E.ID_CARGO
    LEFT JOIN bbf_tipos_contrato TC
        ON TC.ID_TIPO_CONTRATO = E.ID_TIPO_CONTRATO
    WHERE E.ID_EMPLEADO = P_ID_EMPLEADO;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_EMPLEADOS_REPORTE_ACTIVOS` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_EMPLEADOS_REPORTE_ACTIVOS`()
BEGIN

    SELECT

        -- =====================================================
        -- IDENTIFICACIÓN / CARPETA
        -- =====================================================

        FI.NUMERO_CARPETA AS NUMERO_CARPETA,

        CASE
            WHEN UPPER(FI.GENERO) = 'FEMENINO' THEN 'F'
            WHEN UPPER(FI.GENERO) = 'MASCULINO' THEN 'M'
            WHEN UPPER(FI.GENERO) = 'F' THEN 'F'
            WHEN UPPER(FI.GENERO) = 'M' THEN 'M'
            ELSE FI.GENERO
        END AS GENERO,

        TD.NOMBRE AS TIPO_DOCUMENTO,

        E.NUMERO_DOCUMENTO AS DOCUMENTO,

        FI.FECHA_EXPEDICION_DOCUMENTO
            AS FECHA_EXPEDICION_DOCUMENTO,

        CONCAT_WS(
            ' ',
            NULLIF(TRIM(E.APELLIDOS), ''),
            NULLIF(TRIM(E.NOMBRES), '')
        ) AS APELLIDO_NOMBRE_COMPLETO,


        -- =====================================================
        -- INFORMACIÓN LABORAL
        -- =====================================================

        A.NOMBRE AS AREA_CARGO,

        C.NOMBRE AS CARGO_DESEMPENAR,

        CASE MONTH(E.FECHA_INGRESO)
            WHEN 1 THEN 'ENERO'
            WHEN 2 THEN 'FEBRERO'
            WHEN 3 THEN 'MARZO'
            WHEN 4 THEN 'ABRIL'
            WHEN 5 THEN 'MAYO'
            WHEN 6 THEN 'JUNIO'
            WHEN 7 THEN 'JULIO'
            WHEN 8 THEN 'AGOSTO'
            WHEN 9 THEN 'SEPTIEMBRE'
            WHEN 10 THEN 'OCTUBRE'
            WHEN 11 THEN 'NOVIEMBRE'
            WHEN 12 THEN 'DICIEMBRE'
            ELSE NULL
        END AS MES,

        E.FECHA_INGRESO AS FECHA_INGRESO,


        -- =====================================================
        -- COPIA DOCUMENTO IDENTIFICACIÓN
        -- =====================================================

        CASE
            WHEN EXISTS (
                SELECT 1
                FROM bbf_empleado_documentos ED
                INNER JOIN bbf_tipos_documento_laboral TDL
                    ON TDL.ID_TIPO_DOCUMENTO_LABORAL =
                       ED.ID_TIPO_DOCUMENTO_LABORAL
                WHERE ED.ID_EMPLEADO = E.ID_EMPLEADO
                  AND ED.ELIMINADO = 0
                  AND ED.ESTADO_DOCUMENTO IN ('CARGADO', 'VALIDADO')
                  AND LOWER(TDL.NOMBRE) =
                      LOWER('Copia de documento de identidad')
            )
            THEN 'OK'
            ELSE NULL
        END AS COPIA_DOCUMENTO_SI,

        CASE
            WHEN NOT EXISTS (
                SELECT 1
                FROM bbf_empleado_documentos ED
                INNER JOIN bbf_tipos_documento_laboral TDL
                    ON TDL.ID_TIPO_DOCUMENTO_LABORAL =
                       ED.ID_TIPO_DOCUMENTO_LABORAL
                WHERE ED.ID_EMPLEADO = E.ID_EMPLEADO
                  AND ED.ELIMINADO = 0
                  AND ED.ESTADO_DOCUMENTO IN ('CARGADO', 'VALIDADO')
                  AND LOWER(TDL.NOMBRE) =
                      LOWER('Copia de documento de identidad')
            )
            THEN 'X'
            ELSE NULL
        END AS COPIA_DOCUMENTO_NO,


        -- =====================================================
        -- DATOS PERSONALES
        -- =====================================================

        FI.FECHA_NACIMIENTO AS FECHA_NACIMIENTO,

        E.TELEFONO AS CELULAR,

        COALESCE(
            NULLIF(FI.CORREO_PERSONAL, ''),
            E.CORREO
        ) AS CORREO_ELECTRONICO,


        -- =====================================================
        -- CONTRATO FIRMADO
        -- =====================================================

        CASE
            WHEN EXISTS (
                SELECT 1
                FROM bbf_empleado_documentos ED
                INNER JOIN bbf_tipos_documento_laboral TDL
                    ON TDL.ID_TIPO_DOCUMENTO_LABORAL =
                       ED.ID_TIPO_DOCUMENTO_LABORAL
                WHERE ED.ID_EMPLEADO = E.ID_EMPLEADO
                  AND ED.ELIMINADO = 0
                  AND ED.ESTADO_DOCUMENTO IN ('CARGADO', 'VALIDADO')
                  AND LOWER(TDL.NOMBRE) =
                      LOWER('Contrato firmado')
            )
            THEN 'OK'
            ELSE NULL
        END AS CONTRATO_FIRMADO_SI,

        CASE
            WHEN NOT EXISTS (
                SELECT 1
                FROM bbf_empleado_documentos ED
                INNER JOIN bbf_tipos_documento_laboral TDL
                    ON TDL.ID_TIPO_DOCUMENTO_LABORAL =
                       ED.ID_TIPO_DOCUMENTO_LABORAL
                WHERE ED.ID_EMPLEADO = E.ID_EMPLEADO
                  AND ED.ELIMINADO = 0
                  AND ED.ESTADO_DOCUMENTO IN ('CARGADO', 'VALIDADO')
                  AND LOWER(TDL.NOMBRE) =
                      LOWER('Contrato firmado')
            )
            THEN 'X'
            ELSE NULL
        END AS CONTRATO_FIRMADO_NO,


        -- =====================================================
        -- ÚLTIMO CONTRATO
        -- =====================================================

        TC.NOMBRE AS TIPO_CONTRATO_ULTIMO,

        UC.FECHA_FIN AS FECHA_FINALIZACION_CONTRATO,

        UC.SALARIO_BASE AS SALARIO,


        -- =====================================================
        -- ÚLTIMO EXAMEN MÉDICO
        -- =====================================================

        (
            SELECT EM.FECHA_EXAMEN
            FROM bbf_empleado_examenes_medicos EM
            WHERE EM.ID_EMPLEADO = E.ID_EMPLEADO
              AND EM.ELIMINADO = 0
            ORDER BY
                EM.FECHA_EXAMEN DESC,
                EM.ID_EXAMEN_MEDICO DESC
            LIMIT 1
        ) AS ULTIMO_EXAMEN_MEDICO,


        -- =====================================================
        -- CONTRATO DE ARRENDAMIENTO
        -- Se devuelve la fecha del último soporte cargado.
        -- =====================================================

        (
            SELECT DATE(ED.FECHA_CARGA)
            FROM bbf_empleado_documentos ED
            INNER JOIN bbf_tipos_documento_laboral TDL
                ON TDL.ID_TIPO_DOCUMENTO_LABORAL =
                   ED.ID_TIPO_DOCUMENTO_LABORAL
            WHERE ED.ID_EMPLEADO = E.ID_EMPLEADO
              AND ED.ELIMINADO = 0
              AND ED.ESTADO_DOCUMENTO IN ('CARGADO', 'VALIDADO')
              AND LOWER(TDL.NOMBRE) =
                  LOWER('Contrato de arrendamiento')
            ORDER BY
                ED.FECHA_CARGA DESC,
                ED.ID_EMPLEADO_DOCUMENTO DESC
            LIMIT 1
        ) AS CONTRATO_ARRENDAMIENTO,


        FI.DIRECCION_RESIDENCIA
            AS DIRECCION_VIVIENDA,

        FI.PERSONAS_VIVIENDA
            AS CUANTAS_PERSONAS_VIVEN,

        CASE
            WHEN FI.MENORES_ESTUDIAN = 1 THEN 'SI'
            WHEN FI.MENORES_ESTUDIAN = 0 THEN 'NO'
            ELSE NULL
        END AS MENORES_EDAD_ESTUDIAN,


        -- =====================================================
        -- EPS
        -- =====================================================

        CASE
            WHEN SS.ID_EPS IS NOT NULL THEN 'OK'
            ELSE NULL
        END AS EPS_SI,

        CASE
            WHEN SS.ID_EPS IS NULL THEN 'X'
            ELSE NULL
        END AS EPS_NO,

        EPS.NOMBRE AS EPS_CUAL,


        -- =====================================================
        -- PENSIÓN
        -- =====================================================

        CASE
            WHEN SS.ID_FONDO_PENSION IS NOT NULL THEN 'OK'
            ELSE NULL
        END AS PENSION_SI,

        CASE
            WHEN SS.ID_FONDO_PENSION IS NULL THEN 'X'
            ELSE NULL
        END AS PENSION_NO,

        PEN.NOMBRE AS PENSION_CUAL,


        -- =====================================================
        -- ARL
        -- =====================================================

        CASE
            WHEN SS.ID_ARL IS NOT NULL THEN 'OK'
            ELSE NULL
        END AS ARL_SI,

        CASE
            WHEN SS.ID_ARL IS NULL THEN 'X'
            ELSE NULL
        END AS ARL_NO,

        ARL.NOMBRE AS ARL_CUAL,


        -- =====================================================
        -- CARNET ARL
        -- =====================================================

        CASE
            WHEN EXISTS (
                SELECT 1
                FROM bbf_empleado_documentos ED
                INNER JOIN bbf_tipos_documento_laboral TDL
                    ON TDL.ID_TIPO_DOCUMENTO_LABORAL =
                       ED.ID_TIPO_DOCUMENTO_LABORAL
                WHERE ED.ID_EMPLEADO = E.ID_EMPLEADO
                  AND ED.ELIMINADO = 0
                  AND ED.ESTADO_DOCUMENTO IN ('CARGADO', 'VALIDADO')
                  AND LOWER(TDL.NOMBRE) =
                      LOWER('Carnet ARL')
            )
            THEN 'OK'
            ELSE NULL
        END AS ARL_CARNET,


        -- =====================================================
        -- CAJA DE COMPENSACIÓN
        -- =====================================================

        CASE
            WHEN SS.ID_CAJA_COMPENSACION IS NOT NULL THEN 'OK'
            ELSE NULL
        END AS CAJA_COMPENSACION_SI,

        CASE
            WHEN SS.ID_CAJA_COMPENSACION IS NULL THEN 'X'
            ELSE NULL
        END AS CAJA_COMPENSACION_NO,

        CAJA.NOMBRE AS CAJA_COMPENSACION_CUAL,


        -- =====================================================
        -- CESANTÍAS
        -- =====================================================

        CASE
            WHEN SS.ID_FONDO_CESANTIAS IS NOT NULL THEN 'OK'
            ELSE NULL
        END AS CESANTIAS_SI,

        CASE
            WHEN SS.ID_FONDO_CESANTIAS IS NULL THEN 'X'
            ELSE NULL
        END AS CESANTIAS_NO,

        CES.NOMBRE AS CESANTIAS_CUAL,


        -- =====================================================
        -- BATERÍA RIESGO PSICOSOCIAL
        -- Se devuelve la fecha del último soporte cargado.
        -- =====================================================

        (
            SELECT DATE(ED.FECHA_CARGA)
            FROM bbf_empleado_documentos ED
            INNER JOIN bbf_tipos_documento_laboral TDL
                ON TDL.ID_TIPO_DOCUMENTO_LABORAL =
                   ED.ID_TIPO_DOCUMENTO_LABORAL
            WHERE ED.ID_EMPLEADO = E.ID_EMPLEADO
              AND ED.ELIMINADO = 0
              AND ED.ESTADO_DOCUMENTO IN ('CARGADO', 'VALIDADO')
              AND LOWER(TDL.NOMBRE) =
                  LOWER('Batería de riesgo psicosocial')
            ORDER BY
                ED.FECHA_CARGA DESC,
                ED.ID_EMPLEADO_DOCUMENTO DESC
            LIMIT 1
        ) AS BATERIA_RIESGO_PSICOSOCIAL,


        -- =====================================================
        -- ÚLTIMA ENTREGA DE DOTACIÓN
        -- =====================================================

        (
            SELECT MAX(DE.FECHA_ENTREGA)
            FROM bbf_dotacion_entregas DE
            WHERE DE.ID_EMPLEADO = E.ID_EMPLEADO
              AND DE.ELIMINADO = 0
              AND DE.ESTADO <> 'ANULADA'
        ) AS ULTIMA_ENTREGA_DOTACIONES,


        -- =====================================================
        -- TALLA OVEROL
        -- =====================================================

        (
            SELECT TALLA.TALLA
            FROM bbf_empleado_dotacion_tallas EDT
            INNER JOIN bbf_tipos_dotacion TIPO
                ON TIPO.ID_TIPO_DOTACION =
                   EDT.ID_TIPO_DOTACION
            LEFT JOIN bbf_tallas_dotacion TALLA
                ON TALLA.ID_TALLA_DOTACION =
                   EDT.ID_TALLA_DOTACION
            WHERE EDT.ID_EMPLEADO = E.ID_EMPLEADO
              AND LOWER(TIPO.NOMBRE) = LOWER('Overol')
            LIMIT 1
        ) AS TALLA_OVEROL,


        -- =====================================================
        -- TALLA PANTALÓN
        -- =====================================================

        (
            SELECT TALLA.TALLA
            FROM bbf_empleado_dotacion_tallas EDT
            INNER JOIN bbf_tipos_dotacion TIPO
                ON TIPO.ID_TIPO_DOTACION =
                   EDT.ID_TIPO_DOTACION
            LEFT JOIN bbf_tallas_dotacion TALLA
                ON TALLA.ID_TALLA_DOTACION =
                   EDT.ID_TALLA_DOTACION
            WHERE EDT.ID_EMPLEADO = E.ID_EMPLEADO
              AND LOWER(TIPO.NOMBRE) = LOWER('Pantalón')
            LIMIT 1
        ) AS TALLA_PANTALON,


        -- =====================================================
        -- TALLA CAMISA
        -- =====================================================

        (
            SELECT TALLA.TALLA
            FROM bbf_empleado_dotacion_tallas EDT
            INNER JOIN bbf_tipos_dotacion TIPO
                ON TIPO.ID_TIPO_DOTACION =
                   EDT.ID_TIPO_DOTACION
            LEFT JOIN bbf_tallas_dotacion TALLA
                ON TALLA.ID_TALLA_DOTACION =
                   EDT.ID_TALLA_DOTACION
            WHERE EDT.ID_EMPLEADO = E.ID_EMPLEADO
              AND LOWER(TIPO.NOMBRE) = LOWER('Camisa')
            LIMIT 1
        ) AS TALLA_CAMISA,


        -- =====================================================
        -- NÚMERO CALZADO
        -- =====================================================

        (
            SELECT TALLA.TALLA
            FROM bbf_empleado_dotacion_tallas EDT
            INNER JOIN bbf_tipos_dotacion TIPO
                ON TIPO.ID_TIPO_DOTACION =
                   EDT.ID_TIPO_DOTACION
            LEFT JOIN bbf_tallas_dotacion TALLA
                ON TALLA.ID_TALLA_DOTACION =
                   EDT.ID_TALLA_DOTACION
            WHERE EDT.ID_EMPLEADO = E.ID_EMPLEADO
              AND LOWER(TIPO.NOMBRE) = LOWER('Calzado')
            LIMIT 1
        ) AS NUMERO_CALZADO,


        -- =====================================================
        -- OBSERVACIONES
        -- =====================================================

        COALESCE(
            NULLIF(FI.OBSERVACIONES, ''),
            NULLIF(UC.OBSERVACIONES, ''),
            E.OBSERVACIONES
        ) AS OBSERVACIONES,


        -- =====================================================
        -- FINALIZACIÓN DEL CONTRATO
        -- =====================================================

        CASE
            WHEN UC.ESTADO_CONTRATO IN (
                'VENCIDO',
                'FINALIZADO'
            )
            THEN 'SI'

            WHEN UC.ID_EMPLEADO_CONTRATO IS NOT NULL
            THEN 'NO'

            ELSE NULL
        END AS FINALIZACION_CONTRATO,


        -- =====================================================
        -- ESTADO EMPLEADO
        -- =====================================================

        E.ESTADO_EMPLEADO AS ESTADO


    -- =========================================================
    -- EMPLEADO
    -- =========================================================

    FROM bbf_empleados E


    LEFT JOIN bbf_empleado_ficha_ingreso FI
        ON FI.ID_EMPLEADO = E.ID_EMPLEADO
       AND FI.ELIMINADO = 0


    LEFT JOIN bbf_tipos_documento TD
        ON TD.ID_TIPO_DOCUMENTO = E.ID_TIPO_DOCUMENTO


    LEFT JOIN bbf_areas A
        ON A.ID_AREA = E.ID_AREA


    LEFT JOIN bbf_cargos C
        ON C.ID_CARGO = E.ID_CARGO


    -- =========================================================
    -- ÚLTIMO CONTRATO
    -- =========================================================

    LEFT JOIN bbf_empleado_contratos UC
        ON UC.ID_EMPLEADO_CONTRATO = (
            SELECT EC.ID_EMPLEADO_CONTRATO
            FROM bbf_empleado_contratos EC
            WHERE EC.ID_EMPLEADO = E.ID_EMPLEADO
              AND EC.ELIMINADO = 0
              AND EC.ESTADO_CONTRATO <> 'ANULADO'
            ORDER BY
                EC.FECHA_INICIO DESC,
                EC.ID_EMPLEADO_CONTRATO DESC
            LIMIT 1
        )


    LEFT JOIN bbf_tipos_contrato TC
        ON TC.ID_TIPO_CONTRATO = UC.ID_TIPO_CONTRATO


    -- =========================================================
    -- SEGURIDAD SOCIAL
    -- =========================================================

    LEFT JOIN bbf_empleado_seguridad_social SS
        ON SS.ID_EMPLEADO = E.ID_EMPLEADO
       AND SS.ELIMINADO = 0


    LEFT JOIN bbf_entidades_seguridad_social EPS
        ON EPS.ID_ENTIDAD_SEGURIDAD_SOCIAL = SS.ID_EPS


    LEFT JOIN bbf_entidades_seguridad_social ARL
        ON ARL.ID_ENTIDAD_SEGURIDAD_SOCIAL = SS.ID_ARL


    LEFT JOIN bbf_entidades_seguridad_social PEN
        ON PEN.ID_ENTIDAD_SEGURIDAD_SOCIAL =
           SS.ID_FONDO_PENSION


    LEFT JOIN bbf_entidades_seguridad_social CES
        ON CES.ID_ENTIDAD_SEGURIDAD_SOCIAL =
           SS.ID_FONDO_CESANTIAS


    LEFT JOIN bbf_entidades_seguridad_social CAJA
        ON CAJA.ID_ENTIDAD_SEGURIDAD_SOCIAL =
           SS.ID_CAJA_COMPENSACION


    -- =========================================================
    -- SOLO EMPLEADOS ACTIVOS
    -- =========================================================

    WHERE E.ELIMINADO = 0
      AND E.ESTADO_EMPLEADO = 'ACTIVO'


    ORDER BY
        CASE
            WHEN FI.NUMERO_CARPETA REGEXP '^[0-9]+$'
            THEN CAST(FI.NUMERO_CARPETA AS UNSIGNED)
            ELSE 999999999
        END,
        FI.NUMERO_CARPETA,
        E.APELLIDOS,
        E.NOMBRES;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_ENTIDADES_SEGURIDAD_SOCIAL_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_ENTIDADES_SEGURIDAD_SOCIAL_LISTAR`(
    IN P_TIPO VARCHAR(50)
)
BEGIN

    SELECT
        ID_ENTIDAD_SEGURIDAD_SOCIAL,
        TIPO_ENTIDAD AS TIPO,
        NOMBRE,
        NIT AS CODIGO
    FROM bbf_entidades_seguridad_social
    WHERE ACTIVO = 1
      AND TIPO_ENTIDAD = P_TIPO
    ORDER BY NOMBRE ASC;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_HERRAMIENTAS_ACTUALIZAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_HERRAMIENTAS_ACTUALIZAR`(
    in p_id_herramienta int,
    in p_nombre varchar(150),
    in p_descripcion varchar(500)
)
begin

    declare v_existe int default 0;
    declare v_duplicado int default 0;

    select count(*)
    into v_existe
    from bbf_herramientas
    where id_herramienta = p_id_herramienta;

    if v_existe = 0 then
        signal sqlstate '45000'
        set message_text = 'La herramienta no existe';
    end if;

    if p_nombre is null or trim(p_nombre) = '' then
        signal sqlstate '45000'
        set message_text = 'El nombre de la herramienta es obligatorio';
    end if;

    select count(*)
    into v_duplicado
    from bbf_herramientas
    where nombre = trim(p_nombre)
      and id_herramienta <> p_id_herramienta;

    if v_duplicado > 0 then
        signal sqlstate '45000'
        set message_text = 'Ya existe otra herramienta con este nombre';
    end if;

    update bbf_herramientas
    set
        nombre = trim(p_nombre),
        descripcion = nullif(trim(p_descripcion), '')
    where id_herramienta = p_id_herramienta;

    select
        p_id_herramienta as id_herramienta,
        'Herramienta actualizada correctamente' as mensaje;

end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_HERRAMIENTAS_CAMBIAR_ESTADO` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_HERRAMIENTAS_CAMBIAR_ESTADO`(
    in p_id_herramienta int,
    in p_activo tinyint
)
begin

    declare v_existe int default 0;

    select count(*)
    into v_existe
    from bbf_herramientas
    where id_herramienta = p_id_herramienta;

    if v_existe = 0 then
        signal sqlstate '45000'
        set message_text = 'La herramienta no existe';
    end if;

    if p_activo not in (0, 1) then
        signal sqlstate '45000'
        set message_text = 'El estado enviado no es valido';
    end if;

    update bbf_herramientas
    set activo = p_activo
    where id_herramienta = p_id_herramienta;

    select
        p_id_herramienta as id_herramienta,
        p_activo as activo,
        'Estado actualizado correctamente' as mensaje;

end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_HERRAMIENTAS_CREAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_HERRAMIENTAS_CREAR`(
    in p_nombre varchar(150),
    in p_descripcion varchar(500)
)
begin

    declare v_existe int default 0;

    if p_nombre is null or trim(p_nombre) = '' then
        signal sqlstate '45000'
        set message_text = 'El nombre de la herramienta es obligatorio';
    end if;

    select count(*)
    into v_existe
    from bbf_herramientas
    where nombre = trim(p_nombre);

    if v_existe > 0 then
        signal sqlstate '45000'
        set message_text = 'La herramienta ya se encuentra registrada';
    end if;

    insert into bbf_herramientas (
        nombre,
        descripcion,
        activo
    )
    values (
        trim(p_nombre),
        nullif(trim(p_descripcion), ''),
        1
    );

    select
        last_insert_id() as id_herramienta,
        'Herramienta creada correctamente' as mensaje;

end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_HERRAMIENTAS_EMPLEADO_USUARIO_OBTENER` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_HERRAMIENTAS_EMPLEADO_USUARIO_OBTENER`(
    IN P_ID_USUARIO INT
)
BEGIN
    SELECT E.ID_EMPLEADO
    FROM bbf_usuarios U
    INNER JOIN bbf_empleados E ON E.ID_EMPLEADO = U.ID_EMPLEADO
    WHERE U.ID_USUARIO = P_ID_USUARIO
      AND IFNULL(E.ELIMINADO, 0) = 0
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_HERRAMIENTAS_ENTREGAS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_HERRAMIENTAS_ENTREGAS_LISTAR`(
    in p_id_empleado int,
    in p_estado varchar(20)
)
begin

    select
        en.id_entrega,
        en.id_empleado,

        e.numero_documento,
        e.nombres,
        e.apellidos,

        concat(
            e.nombres,
            ' ',
            e.apellidos
        ) as empleado,

        en.fecha_entrega,
        en.estado,
        en.observaciones,
        en.fecha_confirmacion,

        count(d.id_detalle) as total_herramientas,
        coalesce(sum(d.cantidad), 0) as total_unidades,

        en.created_at,
        en.updated_at

    from bbf_herramientas_entregas en

    inner join bbf_empleados e
        on e.id_empleado = en.id_empleado

    left join bbf_herramientas_entrega_detalle d
        on d.id_entrega = en.id_entrega

    where
        (
            p_id_empleado is null
            or en.id_empleado = p_id_empleado
        )

        and
        (
            p_estado is null
            or trim(p_estado) = ''
            or en.estado = p_estado
        )

    group by
        en.id_entrega,
        en.id_empleado,
        e.numero_documento,
        e.nombres,
        e.apellidos,
        en.fecha_entrega,
        en.estado,
        en.observaciones,
        en.fecha_confirmacion,
        en.created_at,
        en.updated_at

    order by
        en.fecha_entrega desc,
        en.id_entrega desc;

end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_HERRAMIENTAS_ENTREGA_CONFIRMAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_HERRAMIENTAS_ENTREGA_CONFIRMAR`(
    IN p_id_entrega INT
)
BEGIN
    DECLARE v_existe INT DEFAULT 0;
    DECLARE v_estado VARCHAR(20);
    DECLARE v_evidencias INT DEFAULT 0;

    SELECT COUNT(*)
      INTO v_existe
    FROM bbf_herramientas_entregas
    WHERE id_entrega = p_id_entrega;

    IF v_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La entrega no existe.';
    END IF;

    SELECT estado
      INTO v_estado
    FROM bbf_herramientas_entregas
    WHERE id_entrega = p_id_entrega;

    IF v_estado = 'confirmada' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La entrega ya se encuentra confirmada.';
    END IF;

    SELECT COUNT(*)
      INTO v_evidencias
    FROM bbf_herramientas_entrega_evidencias
    WHERE id_entrega = p_id_entrega
      AND mime_type LIKE 'image/%';

    IF v_evidencias = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'La entrega requiere al menos una evidencia fotográfica.';
    END IF;

    UPDATE bbf_herramientas_entregas
    SET estado = 'confirmada',
        fecha_confirmacion = CURRENT_TIMESTAMP(),
        updated_at = CURRENT_TIMESTAMP()
    WHERE id_entrega = p_id_entrega;

    SELECT
        p_id_entrega AS id_entrega,
        'confirmada' AS estado,
        'Entrega confirmada correctamente.' AS mensaje;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_HERRAMIENTAS_ENTREGA_CREAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_HERRAMIENTAS_ENTREGA_CREAR`(
    IN p_id_empleado INT,
    IN p_fecha_entrega DATE,
    IN p_observaciones TEXT,
    IN p_detalle LONGTEXT,
    IN p_evidencias LONGTEXT
)
BEGIN
    DECLARE v_existe INT DEFAULT 0;
    DECLARE v_id_entrega INT DEFAULT 0;
    DECLARE v_total INT DEFAULT 0;
    DECLARE v_indice INT DEFAULT 0;
    DECLARE v_id_herramienta INT;
    DECLARE v_cantidad INT;
    DECLARE v_observaciones VARCHAR(500);
    DECLARE v_mensaje VARCHAR(255);

    DECLARE v_nombre_archivo VARCHAR(255);
    DECLARE v_nombre_original VARCHAR(255);
    DECLARE v_archivo_url VARCHAR(500);
    DECLARE v_archivo_ruta VARCHAR(500);
    DECLARE v_mime_type VARCHAR(100);
    DECLARE v_peso_bytes BIGINT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SELECT COUNT(*)
      INTO v_existe
    FROM bbf_empleados
    WHERE ID_EMPLEADO = p_id_empleado
      AND ESTADO_EMPLEADO = 'ACTIVO'
      AND IFNULL(ELIMINADO, 0) = 0;

    IF v_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'El empleado no existe, está inactivo o fue eliminado.';
    END IF;

    IF p_detalle IS NULL
       OR TRIM(p_detalle) = ''
       OR JSON_VALID(p_detalle) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'El detalle de herramientas no contiene un JSON válido.';
    END IF;

    SET v_total = JSON_LENGTH(p_detalle);

    IF v_total IS NULL OR v_total <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Debe seleccionar por lo menos una herramienta.';
    END IF;

    IF p_evidencias IS NULL
       OR TRIM(p_evidencias) = ''
       OR JSON_VALID(p_evidencias) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Las evidencias no contienen un JSON válido.';
    END IF;

    IF JSON_LENGTH(p_evidencias) IS NULL
       OR JSON_LENGTH(p_evidencias) <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'La entrega de herramientas requiere al menos una fotografía.';
    END IF;

    START TRANSACTION;

    INSERT INTO bbf_herramientas_entregas (
        id_empleado,
        fecha_entrega,
        estado,
        observaciones
    )
    VALUES (
        p_id_empleado,
        COALESCE(p_fecha_entrega, CURRENT_DATE()),
        'pendiente',
        NULLIF(TRIM(p_observaciones), '')
    );

    SET v_id_entrega = LAST_INSERT_ID();

    SET v_total = JSON_LENGTH(p_detalle);
    SET v_indice = 0;

    WHILE v_indice < v_total DO
        SET v_id_herramienta = CAST(
            JSON_UNQUOTE(
                JSON_EXTRACT(
                    p_detalle,
                    CONCAT('$[', v_indice, '].id_herramienta')
                )
            ) AS SIGNED
        );

        SET v_cantidad = CAST(
            JSON_UNQUOTE(
                JSON_EXTRACT(
                    p_detalle,
                    CONCAT('$[', v_indice, '].cantidad')
                )
            ) AS SIGNED
        );

        SET v_observaciones = NULLIF(
            JSON_UNQUOTE(
                JSON_EXTRACT(
                    p_detalle,
                    CONCAT('$[', v_indice, '].observaciones')
                )
            ),
            'null'
        );

        IF v_id_herramienta IS NULL OR v_id_herramienta <= 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Uno de los elementos no contiene id_herramienta válido.';
        END IF;

        SELECT COUNT(*)
          INTO v_existe
        FROM bbf_herramientas
        WHERE id_herramienta = v_id_herramienta
          AND activo = 1;

        IF v_existe = 0 THEN
            SET v_mensaje = CONCAT(
                'La herramienta ',
                v_id_herramienta,
                ' no existe o se encuentra inactiva.'
            );

            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = v_mensaje;
        END IF;

        IF v_cantidad IS NULL THEN
            SET v_cantidad = 1;
        END IF;

        IF v_cantidad <= 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'La cantidad de herramientas debe ser mayor a cero.';
        END IF;

        INSERT INTO bbf_herramientas_entrega_detalle (
            id_entrega,
            id_herramienta,
            cantidad,
            observaciones
        )
        VALUES (
            v_id_entrega,
            v_id_herramienta,
            v_cantidad,
            NULLIF(TRIM(v_observaciones), '')
        );

        SET v_indice = v_indice + 1;
    END WHILE;

    SET v_total = JSON_LENGTH(p_evidencias);
    SET v_indice = 0;

    WHILE v_indice < v_total DO
        SET v_nombre_archivo = NULLIF(
            TRIM(
                JSON_UNQUOTE(
                    JSON_EXTRACT(
                        p_evidencias,
                        CONCAT('$[', v_indice, '].nombre_archivo')
                    )
                )
            ),
            ''
        );

        SET v_nombre_original = NULLIF(
            JSON_UNQUOTE(
                JSON_EXTRACT(
                    p_evidencias,
                    CONCAT('$[', v_indice, '].nombre_original')
                )
            ),
            'null'
        );

        SET v_archivo_url = NULLIF(
            JSON_UNQUOTE(
                JSON_EXTRACT(
                    p_evidencias,
                    CONCAT('$[', v_indice, '].archivo_url')
                )
            ),
            'null'
        );

        SET v_archivo_ruta = NULLIF(
            JSON_UNQUOTE(
                JSON_EXTRACT(
                    p_evidencias,
                    CONCAT('$[', v_indice, '].archivo_ruta')
                )
            ),
            'null'
        );

        SET v_mime_type = LOWER(
            NULLIF(
                TRIM(
                    JSON_UNQUOTE(
                        JSON_EXTRACT(
                            p_evidencias,
                            CONCAT('$[', v_indice, '].mime_type')
                        )
                    )
                ),
                ''
            )
        );

        SET v_peso_bytes = CAST(
            JSON_UNQUOTE(
                JSON_EXTRACT(
                    p_evidencias,
                    CONCAT('$[', v_indice, '].peso_bytes')
                )
            ) AS SIGNED
        );

        SET v_archivo_url = NULLIF(TRIM(v_archivo_url), '');
        SET v_archivo_ruta = NULLIF(TRIM(v_archivo_ruta), '');

        IF v_nombre_archivo IS NULL THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'El nombre interno de la fotografía es obligatorio.';
        END IF;

        IF v_mime_type IS NULL
           OR v_mime_type NOT LIKE 'image/%' THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Las evidencias de herramientas deben ser fotografías.';
        END IF;

        IF (
            (v_archivo_url IS NULL AND v_archivo_ruta IS NULL)
            OR
            (v_archivo_url IS NOT NULL AND v_archivo_ruta IS NOT NULL)
        ) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'La fotografía debe tener URL o ruta física, pero no ambas.';
        END IF;

        IF v_peso_bytes IS NOT NULL AND v_peso_bytes <= 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'El peso de la fotografía debe ser mayor a cero.';
        END IF;

        INSERT INTO bbf_herramientas_entrega_evidencias (
            id_entrega,
            nombre_archivo,
            nombre_original,
            archivo_url,
            archivo_ruta,
            mime_type,
            peso_bytes
        )
        VALUES (
            v_id_entrega,
            v_nombre_archivo,
            NULLIF(TRIM(v_nombre_original), ''),
            v_archivo_url,
            v_archivo_ruta,
            v_mime_type,
            v_peso_bytes
        );

        SET v_indice = v_indice + 1;
    END WHILE;

    COMMIT;

    SELECT
        v_id_entrega AS id_entrega,
        'pendiente' AS estado,
        'Entrega registrada correctamente.' AS mensaje;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_HERRAMIENTAS_ENTREGA_DETALLE_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_HERRAMIENTAS_ENTREGA_DETALLE_LISTAR`(
    in p_id_entrega int
)
begin

    select
        d.id_detalle,
        d.id_entrega,
        d.id_herramienta,

        h.nombre as herramienta,
        h.descripcion,

        d.cantidad,
        d.observaciones,

        d.created_at,
        d.updated_at

    from bbf_herramientas_entrega_detalle d

    inner join bbf_herramientas h
        on h.id_herramienta = d.id_herramienta

    where d.id_entrega = p_id_entrega

    order by h.nombre asc;

end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_HERRAMIENTAS_ENTREGA_ELIMINAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_HERRAMIENTAS_ENTREGA_ELIMINAR`(
    in p_id_entrega int
)
begin

    declare v_existe int default 0;
    declare v_estado varchar(20);

    declare exit handler for sqlexception
    begin
        rollback;
        resignal;
    end;


    select count(*)
    into v_existe
    from bbf_herramientas_entregas
    where id_entrega = p_id_entrega;


    if v_existe = 0 then
        signal sqlstate '45000'
        set message_text = 'La entrega no existe';
    end if;


    select estado
    into v_estado
    from bbf_herramientas_entregas
    where id_entrega = p_id_entrega;


    if v_estado = 'confirmada' then
        signal sqlstate '45000'
        set message_text = 'No se puede eliminar una entrega confirmada';
    end if;


    start transaction;


    delete from bbf_herramientas_entrega_detalle
    where id_entrega = p_id_entrega;


    delete from bbf_herramientas_entregas
    where id_entrega = p_id_entrega;


    commit;


    select
        p_id_entrega as id_entrega,
        'Entrega eliminada correctamente' as mensaje;

end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_HERRAMIENTAS_ENTREGA_EVIDENCIAS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_HERRAMIENTAS_ENTREGA_EVIDENCIAS_LISTAR`(
    IN p_id_entrega INT
)
BEGIN
    SELECT
        EV.id_evidencia,
        EV.id_entrega,
        EV.nombre_archivo,
        EV.nombre_original,
        EV.archivo_url,
        EV.archivo_ruta,
        EV.mime_type,
        EV.peso_bytes,
        EV.created_at
    FROM bbf_herramientas_entrega_evidencias EV
    WHERE EV.id_entrega = p_id_entrega
    ORDER BY EV.id_evidencia ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_HERRAMIENTAS_ENTREGA_OBTENER` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_HERRAMIENTAS_ENTREGA_OBTENER`(
    in p_id_entrega int
)
begin

    select
        en.id_entrega,
        en.id_empleado,

        e.numero_documento,
        e.nombres,
        e.apellidos,

        concat(
            e.nombres,
            ' ',
            e.apellidos
        ) as empleado,

        en.fecha_entrega,
        en.estado,
        en.observaciones,
        en.fecha_confirmacion,
        en.created_at,
        en.updated_at

    from bbf_herramientas_entregas en

    inner join bbf_empleados e
        on e.id_empleado = en.id_empleado

    where en.id_entrega = p_id_entrega;

end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_HERRAMIENTAS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_HERRAMIENTAS_LISTAR`(
    in p_solo_activos tinyint
)
begin

    select
        h.id_herramienta,
        h.nombre,
        h.descripcion,
        h.activo,
        h.created_at,
        h.updated_at
    from bbf_herramientas h
    where
        p_solo_activos = 0
        or h.activo = 1
    order by h.nombre asc;

end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_HERRAMIENTAS_MIS_ENTREGAS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_HERRAMIENTAS_MIS_ENTREGAS_LISTAR`(
    IN P_ID_EMPLEADO INT
)
BEGIN
    SELECT
        HE.ID_ENTREGA,
        HE.FECHA_ENTREGA,
        HE.ESTADO,
        HE.OBSERVACIONES,
        HE.FECHA_CONFIRMACION,
        COALESCE(SUM(HD.CANTIDAD), 0) AS TOTAL_HERRAMIENTAS
    FROM bbf_herramientas_entregas HE
    LEFT JOIN bbf_herramientas_entrega_detalle HD
        ON HD.ID_ENTREGA = HE.ID_ENTREGA
    WHERE HE.ID_EMPLEADO = P_ID_EMPLEADO
    GROUP BY
        HE.ID_ENTREGA,
        HE.FECHA_ENTREGA,
        HE.ESTADO,
        HE.OBSERVACIONES,
        HE.FECHA_CONFIRMACION
    ORDER BY HE.FECHA_ENTREGA DESC, HE.ID_ENTREGA DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_HERRAMIENTAS_MI_ENTREGA_CONFIRMAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_HERRAMIENTAS_MI_ENTREGA_CONFIRMAR`(
    IN p_id_entrega INT,
    IN p_id_empleado INT,
    IN p_id_usuario INT
)
BEGIN
    DECLARE v_estado VARCHAR(20);
    DECLARE v_evidencias INT DEFAULT 0;

    SET v_estado = NULL;

    SELECT HE.estado
      INTO v_estado
    FROM bbf_herramientas_entregas HE
    WHERE HE.id_entrega = p_id_entrega
      AND HE.id_empleado = p_id_empleado
    LIMIT 1;

    IF v_estado IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La entrega de herramientas no existe.';
    END IF;

    IF LOWER(v_estado) = 'confirmada' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'La entrega de herramientas ya fue confirmada.';
    END IF;

    SELECT COUNT(*)
      INTO v_evidencias
    FROM bbf_herramientas_entrega_evidencias
    WHERE id_entrega = p_id_entrega
      AND mime_type LIKE 'image/%';

    IF v_evidencias = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'La entrega requiere al menos una evidencia fotográfica.';
    END IF;

    UPDATE bbf_herramientas_entregas
    SET estado = 'confirmada',
        fecha_confirmacion = CURRENT_TIMESTAMP(),
        updated_at = CURRENT_TIMESTAMP()
    WHERE id_entrega = p_id_entrega
      AND id_empleado = p_id_empleado;

    SELECT
        id_entrega,
        estado,
        fecha_confirmacion,
        p_id_usuario AS id_usuario_confirmacion
    FROM bbf_herramientas_entregas
    WHERE id_entrega = p_id_entrega
      AND id_empleado = p_id_empleado;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_HERRAMIENTAS_MI_ENTREGA_DETALLE_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_HERRAMIENTAS_MI_ENTREGA_DETALLE_LISTAR`(
    IN P_ID_ENTREGA INT,
    IN P_ID_EMPLEADO INT
)
BEGIN
    SELECT
        HD.ID_DETALLE,
        HD.ID_HERRAMIENTA,
        H.NOMBRE AS HERRAMIENTA,
        HD.CANTIDAD,
        HD.OBSERVACIONES
    FROM bbf_herramientas_entrega_detalle HD
    INNER JOIN bbf_herramientas_entregas HE
        ON HE.ID_ENTREGA = HD.ID_ENTREGA
       AND HE.ID_EMPLEADO = P_ID_EMPLEADO
    INNER JOIN bbf_herramientas H
        ON H.ID_HERRAMIENTA = HD.ID_HERRAMIENTA
    WHERE HD.ID_ENTREGA = P_ID_ENTREGA
    ORDER BY HD.ID_DETALLE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_HERRAMIENTAS_MI_ENTREGA_OBTENER` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_HERRAMIENTAS_MI_ENTREGA_OBTENER`(
    IN P_ID_ENTREGA INT,
    IN P_ID_EMPLEADO INT
)
BEGIN
    SELECT
        HE.ID_ENTREGA,
        HE.FECHA_ENTREGA,
        HE.ESTADO,
        HE.OBSERVACIONES,
        HE.FECHA_CONFIRMACION,
        HE.CREATED_AT,
        HE.UPDATED_AT
    FROM bbf_herramientas_entregas HE
    WHERE HE.ID_ENTREGA = P_ID_ENTREGA
      AND HE.ID_EMPLEADO = P_ID_EMPLEADO
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_LOGIN_MARCAR_EXITOSO` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_LOGIN_MARCAR_EXITOSO`(
    IN P_ID_USUARIO INT
)
BEGIN
    UPDATE bbf_usuarios
    SET
        ULTIMO_LOGIN = CURRENT_TIMESTAMP,
        INTENTOS_FALLIDOS = 0,
        FECHA_BLOQUEO = NULL
    WHERE ID_USUARIO = P_ID_USUARIO;

    SELECT ROW_COUNT() AS FILAS_AFECTADAS;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_LOGIN_MARCAR_FALLIDO` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_LOGIN_MARCAR_FALLIDO`(
    IN P_ID_USUARIO INT
)
BEGIN
    UPDATE bbf_usuarios
    SET
        INTENTOS_FALLIDOS = INTENTOS_FALLIDOS + 1,
        ESTADO = CASE
            WHEN INTENTOS_FALLIDOS + 1 >= 5 THEN 'BLOQUEADO'
            ELSE ESTADO
        END,
        FECHA_BLOQUEO = CASE
            WHEN INTENTOS_FALLIDOS + 1 >= 5 THEN CURRENT_TIMESTAMP
            ELSE FECHA_BLOQUEO
        END
    WHERE ID_USUARIO = P_ID_USUARIO;

    SELECT
        ID_USUARIO,
        ESTADO,
        INTENTOS_FALLIDOS,
        FECHA_BLOQUEO
    FROM bbf_usuarios
    WHERE ID_USUARIO = P_ID_USUARIO;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_LOGIN_OBTENER_USUARIO` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_LOGIN_OBTENER_USUARIO`(
    IN P_USUARIO_O_CORREO VARCHAR(150)
)
BEGIN
    SELECT
        U.ID_USUARIO,
        U.ID_EMPLEADO,
        U.NOMBRE_USUARIO,
        U.CORREO,
        U.PASSWORD_HASH,
        U.TIPO_USUARIO,
        U.TIPO_AUTENTICACION,
        U.REQUIERE_CAMBIO_PASSWORD,
        U.CORREO_VERIFICADO,
        U.ESTADO,
        U.INTENTOS_FALLIDOS,
        U.FECHA_BLOQUEO,
        U.ULTIMO_LOGIN,
        E.NOMBRES,
        E.APELLIDOS,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS) AS NOMBRE_COMPLETO
    FROM bbf_usuarios U
    LEFT JOIN bbf_empleados E ON E.ID_EMPLEADO = U.ID_EMPLEADO
    WHERE U.CORREO = P_USUARIO_O_CORREO
       OR U.NOMBRE_USUARIO = P_USUARIO_O_CORREO
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_LOG_AUDITORIA_CREAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_LOG_AUDITORIA_CREAR`(
    IN P_ID_USUARIO INT,
    IN P_MODULO VARCHAR(100),
    IN P_ACCION VARCHAR(100),
    IN P_ENTIDAD VARCHAR(100),
    IN P_ENTIDAD_ID INT,
    IN P_DATOS_ANTERIORES JSON,
    IN P_DATOS_NUEVOS JSON,
    IN P_IP_ORIGEN VARCHAR(50),
    IN P_USER_AGENT VARCHAR(500)
)
BEGIN
    INSERT INTO bbf_log_auditoria (
        ID_USUARIO,
        MODULO,
        ACCION,
        ENTIDAD,
        ENTIDAD_ID,
        DATOS_ANTERIORES,
        DATOS_NUEVOS,
        IP_ORIGEN,
        USER_AGENT
    )
    VALUES (
        P_ID_USUARIO,
        P_MODULO,
        P_ACCION,
        P_ENTIDAD,
        P_ENTIDAD_ID,
        P_DATOS_ANTERIORES,
        P_DATOS_NUEVOS,
        P_IP_ORIGEN,
        P_USER_AGENT
    );

    SELECT LAST_INSERT_ID() AS ID_LOG;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_LOG_AUDITORIA_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_LOG_AUDITORIA_LISTAR`(
    IN P_FECHA_INICIO DATETIME,
    IN P_FECHA_FIN DATETIME,
    IN P_ID_USUARIO INT,
    IN P_MODULO VARCHAR(100),
    IN P_ACCION VARCHAR(100)
)
BEGIN
    SELECT
        L.ID_LOG,
        L.ID_USUARIO,
        U.CORREO AS USUARIO_CORREO,
        U.NOMBRE_USUARIO,
        L.MODULO,
        L.ACCION,
        L.ENTIDAD,
        L.ENTIDAD_ID,
        L.IP_ORIGEN,
        L.USER_AGENT,
        L.CREATED_AT
    FROM bbf_log_auditoria L
    LEFT JOIN bbf_usuarios U ON U.ID_USUARIO = L.ID_USUARIO
    WHERE
        (P_FECHA_INICIO IS NULL OR L.CREATED_AT >= P_FECHA_INICIO)
        AND (P_FECHA_FIN IS NULL OR L.CREATED_AT <= P_FECHA_FIN)
        AND (P_ID_USUARIO IS NULL OR P_ID_USUARIO = 0 OR L.ID_USUARIO = P_ID_USUARIO)
        AND (P_MODULO IS NULL OR P_MODULO = '' OR L.MODULO = P_MODULO)
        AND (P_ACCION IS NULL OR P_ACCION = '' OR L.ACCION = P_ACCION)
    ORDER BY L.CREATED_AT DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_LOG_AUDITORIA_OBTENER_POR_ID` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_LOG_AUDITORIA_OBTENER_POR_ID`(
    IN P_ID_LOG BIGINT
)
BEGIN
    SELECT
        L.ID_LOG,
        L.ID_USUARIO,
        U.CORREO AS USUARIO_CORREO,
        U.NOMBRE_USUARIO,
        L.MODULO,
        L.ACCION,
        L.ENTIDAD,
        L.ENTIDAD_ID,
        L.DATOS_ANTERIORES,
        L.DATOS_NUEVOS,
        L.IP_ORIGEN,
        L.USER_AGENT,
        L.CREATED_AT
    FROM bbf_log_auditoria L
    LEFT JOIN bbf_usuarios U ON U.ID_USUARIO = L.ID_USUARIO
    WHERE L.ID_LOG = P_ID_LOG;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_MUNICIPIOS_LISTAR_POR_DEPARTAMENTO` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_MUNICIPIOS_LISTAR_POR_DEPARTAMENTO`(
    IN P_ID_DEPARTAMENTO INT
)
BEGIN
    SELECT
        ID_MUNICIPIO,
        ID_DEPARTAMENTO,
        CODIGO_DANE,
        NOMBRE
    FROM bbf_municipios
    WHERE ID_DEPARTAMENTO = P_ID_DEPARTAMENTO
      AND ACTIVO = 1
    ORDER BY NOMBRE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_PARAMETROS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_PARAMETROS_LISTAR`(
    IN P_GRUPO VARCHAR(100),
    IN P_CODIGO VARCHAR(100),
    IN P_INCLUIR_INACTIVOS TINYINT
)
BEGIN
    SELECT
        PS.`ID_PARAMETRO`,
        PS.`CODIGO`,
        PS.`NOMBRE`,
        PS.`GRUPO`,
        PS.`DESCRIPCION`,
        PS.`TIPO_DATO`,
        PS.`VALOR`,
        PS.`UNIDAD_MEDIDA`,
        PS.`VIGENCIA_DESDE`,
        PS.`VIGENCIA_HASTA`,
        PS.`ACTIVO`,
        PS.`EDITABLE`,
        PS.`ID_CREADO_POR`,
        UC.`NOMBRE_USUARIO` AS `CREADO_POR`,
        PS.`ID_ACTUALIZADO_POR`,
        UA.`NOMBRE_USUARIO` AS `ACTUALIZADO_POR`,
        PS.`CREATED_AT`,
        PS.`UPDATED_AT`

    FROM `bbf_parametros_sistema` PS

    LEFT JOIN `bbf_usuarios` UC
        ON UC.`ID_USUARIO` = PS.`ID_CREADO_POR`

    LEFT JOIN `bbf_usuarios` UA
        ON UA.`ID_USUARIO` = PS.`ID_ACTUALIZADO_POR`

    WHERE (
        NULLIF(TRIM(P_GRUPO), '') IS NULL
        OR PS.`GRUPO` = UPPER(TRIM(P_GRUPO))
    )
    AND (
        NULLIF(TRIM(P_CODIGO), '') IS NULL
        OR PS.`CODIGO` = UPPER(TRIM(P_CODIGO))
    )
    AND (
        IFNULL(P_INCLUIR_INACTIVOS, 0) = 1
        OR PS.`ACTIVO` = 1
    )

    ORDER BY
        PS.`GRUPO`,
        PS.`CODIGO`,
        PS.`VIGENCIA_DESDE` DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_PARAMETRO_VIGENTE_OBTENER` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_PARAMETRO_VIGENTE_OBTENER`(
    IN P_CODIGO VARCHAR(100),
    IN P_FECHA DATE
)
BEGIN
    DECLARE V_FECHA DATE;

    SET V_FECHA = IFNULL(P_FECHA, CURRENT_DATE());

    SELECT
        PS.`ID_PARAMETRO`,
        PS.`CODIGO`,
        PS.`NOMBRE`,
        PS.`GRUPO`,
        PS.`DESCRIPCION`,
        PS.`TIPO_DATO`,
        PS.`VALOR`,
        PS.`UNIDAD_MEDIDA`,
        PS.`VIGENCIA_DESDE`,
        PS.`VIGENCIA_HASTA`,
        PS.`ACTIVO`,
        PS.`EDITABLE`,
        PS.`CREATED_AT`,
        PS.`UPDATED_AT`

    FROM `bbf_parametros_sistema` PS

    WHERE PS.`CODIGO` = UPPER(TRIM(P_CODIGO))
      AND PS.`ACTIVO` = 1
      AND PS.`VIGENCIA_DESDE` <= V_FECHA
      AND (
          PS.`VIGENCIA_HASTA` IS NULL
          OR PS.`VIGENCIA_HASTA` >= V_FECHA
      )

    ORDER BY
        PS.`VIGENCIA_DESDE` DESC,
        PS.`ID_PARAMETRO` DESC

    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_PASSWORD_RESET_CREAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_PASSWORD_RESET_CREAR`(
    IN P_ID_USUARIO INT,
    IN P_TOKEN_HASH VARCHAR(255),
    IN P_FECHA_EXPIRACION DATETIME,
    IN P_IP_SOLICITUD VARCHAR(50)
)
BEGIN
    -- Se invalidan tokens anteriores pendientes.
    UPDATE bbf_usuario_password_reset
    SET
        USADO = 1,
        FECHA_USO = CURRENT_TIMESTAMP
    WHERE ID_USUARIO = P_ID_USUARIO
      AND USADO = 0;

    INSERT INTO bbf_usuario_password_reset (
        ID_USUARIO,
        TOKEN_HASH,
        FECHA_EXPIRACION,
        IP_SOLICITUD,
        USADO
    )
    VALUES (
        P_ID_USUARIO,
        P_TOKEN_HASH,
        P_FECHA_EXPIRACION,
        P_IP_SOLICITUD,
        0
    );

    SELECT LAST_INSERT_ID() AS ID_RESET;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_PASSWORD_RESET_MARCAR_USADO` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_PASSWORD_RESET_MARCAR_USADO`(
    IN P_ID_RESET BIGINT
)
BEGIN
    UPDATE bbf_usuario_password_reset
    SET
        USADO = 1,
        FECHA_USO = CURRENT_TIMESTAMP
    WHERE ID_RESET = P_ID_RESET
      AND USADO = 0;

    SELECT ROW_COUNT() AS FILAS_AFECTADAS;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_PASSWORD_RESET_OBTENER` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_PASSWORD_RESET_OBTENER`(
    IN P_TOKEN_HASH VARCHAR(255)
)
BEGIN
    SELECT
        PR.ID_RESET,
        PR.ID_USUARIO,
        PR.TOKEN_HASH,
        PR.FECHA_CREACION,
        PR.FECHA_EXPIRACION,
        PR.FECHA_USO,
        PR.USADO,
        U.CORREO,
        U.NOMBRE_USUARIO,
        U.ESTADO
    FROM bbf_usuario_password_reset PR
    INNER JOIN bbf_usuarios U ON U.ID_USUARIO = PR.ID_USUARIO
    WHERE PR.TOKEN_HASH = P_TOKEN_HASH
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_PERMISOS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_PERMISOS_LISTAR`(
    IN P_SOLO_ACTIVOS TINYINT,
    IN P_MODULO VARCHAR(100)
)
BEGIN
    SELECT
        ID_PERMISO,
        CODIGO,
        NOMBRE,
        DESCRIPCION,
        MODULO,
        ACTIVO,
        CREATED_AT,
        UPDATED_AT
    FROM bbf_permisos
    WHERE
        (P_SOLO_ACTIVOS = 0 OR ACTIVO = 1)
        AND (P_MODULO IS NULL OR P_MODULO = '' OR MODULO = P_MODULO)
    ORDER BY MODULO ASC, CODIGO ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_ROLES_CAMBIAR_ESTADO` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_ROLES_CAMBIAR_ESTADO`(
    IN P_ID_ROL INT,
    IN P_ACTIVO TINYINT
)
BEGIN
    UPDATE bbf_roles
    SET 
        ACTIVO = P_ACTIVO,
        ELIMINADO = 0,
        FECHA_ELIMINACION = NULL,
        UPDATED_AT = CURRENT_TIMESTAMP
    WHERE ID_ROL = P_ID_ROL
      AND ELIMINADO = 0;

    SELECT ROW_COUNT() AS FILAS_AFECTADAS;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_ROLES_CREAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_ROLES_CREAR`(
    IN P_NOMBRE VARCHAR(100),
    IN P_DESCRIPCION TEXT
)
BEGIN
    INSERT INTO bbf_roles (
        NOMBRE,
        DESCRIPCION,
        ACTIVO
    )
    VALUES (
        P_NOMBRE,
        P_DESCRIPCION,
        1
    );

    SELECT LAST_INSERT_ID() AS ID_ROL;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_ROLES_ELIMINAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_ROLES_ELIMINAR`(
    IN P_ID_ROL INT
)
BEGIN
    UPDATE bbf_roles
    SET
        ACTIVO = 0,
        ELIMINADO = 1,
        FECHA_ELIMINACION = CURRENT_TIMESTAMP,
        UPDATED_AT = CURRENT_TIMESTAMP
    WHERE ID_ROL = P_ID_ROL
      AND ELIMINADO = 0;

    SELECT ROW_COUNT() AS FILAS_AFECTADAS;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_ROLES_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_ROLES_LISTAR`(IN P_SOLO_ACTIVOS TINYINT)
BEGIN SELECT ID_ROL, NOMBRE, DESCRIPCION, ACTIVO, CREATED_AT, UPDATED_AT FROM bbf_roles WHERE ELIMINADO = 0 AND (P_SOLO_ACTIVOS = 0 OR ACTIVO = 1) ORDER BY NOMBRE ASC; END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_ROL_OBTENER_PERMISOS` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_ROL_OBTENER_PERMISOS`(
    IN P_ID_ROL INT
)
BEGIN
    SELECT
        P.ID_PERMISO,
        P.CODIGO,
        P.NOMBRE,
        P.DESCRIPCION,
        P.MODULO,
        P.ACTIVO
    FROM bbf_rol_permisos RP
    INNER JOIN bbf_permisos P ON P.ID_PERMISO = RP.ID_PERMISO
    WHERE RP.ID_ROL = P_ID_ROL
    ORDER BY P.MODULO ASC, P.CODIGO ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_ROL_PERMISOS_ASIGNAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_ROL_PERMISOS_ASIGNAR`(
    IN P_ID_ROL INT,
    IN P_ID_PERMISO INT
)
BEGIN
    INSERT IGNORE INTO bbf_rol_permisos (
        ID_ROL,
        ID_PERMISO
    )
    VALUES (
        P_ID_ROL,
        P_ID_PERMISO
    );

    SELECT ROW_COUNT() AS FILAS_AFECTADAS;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_ROL_PERMISOS_QUITAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_ROL_PERMISOS_QUITAR`(
    IN P_ID_ROL INT,
    IN P_ID_PERMISO INT
)
BEGIN
    DELETE FROM bbf_rol_permisos
    WHERE ID_ROL = P_ID_ROL
      AND ID_PERMISO = P_ID_PERMISO;

    SELECT ROW_COUNT() AS FILAS_AFECTADAS;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_TIPOS_CONTRATO_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_TIPOS_CONTRATO_LISTAR`(
    IN P_SOLO_ACTIVOS TINYINT
)
BEGIN
    SELECT
        ID_TIPO_CONTRATO,
        NOMBRE,
        DESCRIPCION,
        ACTIVO,
        CREATED_AT,
        UPDATED_AT
    FROM bbf_tipos_contrato
    WHERE P_SOLO_ACTIVOS = 0 OR ACTIVO = 1
    ORDER BY NOMBRE ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_TIPOS_DOCUMENTO_LABORAL_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_TIPOS_DOCUMENTO_LABORAL_LISTAR`(
    IN P_SOLO_ACTIVOS TINYINT,
    IN P_APLICA_ASPIRANTE TINYINT,
    IN P_APLICA_CONTRATACION TINYINT,
    IN P_APLICA_RETIRO TINYINT
)
BEGIN
    SELECT
        ID_TIPO_DOCUMENTO_LABORAL,
        NOMBRE,
        DESCRIPCION,
        OBLIGATORIO,
        REQUIERE_VENCIMIENTO,
        APLICA_ASPIRANTE,
        APLICA_CONTRATACION,
        APLICA_RETIRO,
        ACTIVO,
        CREATED_AT,
        UPDATED_AT
    FROM bbf_tipos_documento_laboral
    WHERE
        (P_SOLO_ACTIVOS IS NULL OR P_SOLO_ACTIVOS = 0 OR ACTIVO = 1)
        AND (P_APLICA_ASPIRANTE IS NULL OR APLICA_ASPIRANTE = P_APLICA_ASPIRANTE)
        AND (P_APLICA_CONTRATACION IS NULL OR APLICA_CONTRATACION = P_APLICA_CONTRATACION)
        AND (P_APLICA_RETIRO IS NULL OR APLICA_RETIRO = P_APLICA_RETIRO)
    ORDER BY OBLIGATORIO DESC, NOMBRE ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_TIPOS_DOCUMENTO_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_TIPOS_DOCUMENTO_LISTAR`(IN P_SOLO_ACTIVOS TINYINT)
BEGIN
    SELECT
        ID_TIPO_DOCUMENTO,
        NOMBRE,
        ACTIVO,
        CREATED_AT,
        UPDATED_AT
    FROM bbf_tipos_documento
    WHERE COALESCE(P_SOLO_ACTIVOS, 1) = 0
        OR ACTIVO = 1
    ORDER BY NOMBRE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_TIPOS_EXAMEN_MEDICO_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_TIPOS_EXAMEN_MEDICO_LISTAR`()
BEGIN

    SELECT
        ID_TIPO_EXAMEN_MEDICO,
        NOMBRE,
        DESCRIPCION,
        ACTIVO
    FROM bbf_tipos_examen_medico
    WHERE ACTIVO = 1
    ORDER BY NOMBRE ASC;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_USUARIOS_ACTUALIZAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_USUARIOS_ACTUALIZAR`(
    IN P_ID_USUARIO INT,
    IN P_ID_EMPLEADO INT,
    IN P_NOMBRE_USUARIO VARCHAR(100),
    IN P_CORREO VARCHAR(150),
    IN P_TIPO_USUARIO VARCHAR(50),
    IN P_TIPO_AUTENTICACION VARCHAR(50),
    IN P_REQUIERE_CAMBIO_PASSWORD TINYINT,
    IN P_CORREO_VERIFICADO TINYINT,
    IN P_ESTADO VARCHAR(50)
)
BEGIN
    DECLARE V_DOMINIO VARCHAR(150);
    DECLARE V_EXISTE_DOMINIO INT DEFAULT 0;

    SET V_DOMINIO = SUBSTRING_INDEX(P_CORREO, '@', -1);

    IF P_TIPO_AUTENTICACION = 'DOMINIO_EMPRESA' THEN

        SELECT COUNT(*)
        INTO V_EXISTE_DOMINIO
        FROM bbf_dominios_autorizados
        WHERE DOMINIO = V_DOMINIO
          AND ACTIVO = 1;

        IF V_EXISTE_DOMINIO = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El correo no pertenece a un dominio autorizado.';
        END IF;

    END IF;

    UPDATE bbf_usuarios
    SET
        ID_EMPLEADO = P_ID_EMPLEADO,
        NOMBRE_USUARIO = P_NOMBRE_USUARIO,
        CORREO = P_CORREO,
        TIPO_USUARIO = P_TIPO_USUARIO,
        TIPO_AUTENTICACION = P_TIPO_AUTENTICACION,
        REQUIERE_CAMBIO_PASSWORD = P_REQUIERE_CAMBIO_PASSWORD,
        CORREO_VERIFICADO = P_CORREO_VERIFICADO,
        ESTADO = P_ESTADO
    WHERE ID_USUARIO = P_ID_USUARIO;

    SELECT ROW_COUNT() AS FILAS_AFECTADAS;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_USUARIOS_CAMBIAR_ESTADO` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_USUARIOS_CAMBIAR_ESTADO`(
    IN P_ID_USUARIO INT,
    IN P_ESTADO VARCHAR(50)
)
BEGIN
    UPDATE bbf_usuarios
    SET
        ESTADO = P_ESTADO,
        FECHA_BLOQUEO = CASE
            WHEN P_ESTADO = 'BLOQUEADO' THEN CURRENT_TIMESTAMP
            ELSE NULL
        END,
        INTENTOS_FALLIDOS = CASE
            WHEN P_ESTADO = 'ACTIVO' THEN 0
            ELSE INTENTOS_FALLIDOS
        END,
        UPDATED_AT = CURRENT_TIMESTAMP
    WHERE ID_USUARIO = P_ID_USUARIO
      AND P_ESTADO IN ('ACTIVO', 'INACTIVO', 'BLOQUEADO', 'ELIMINADO');

    SELECT ROW_COUNT() AS FILAS_AFECTADAS;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_USUARIOS_CAMBIAR_PASSWORD` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_USUARIOS_CAMBIAR_PASSWORD`(
    IN P_ID_USUARIO INT,
    IN P_PASSWORD_HASH_NUEVO VARCHAR(255),
    IN P_GUARDAR_HISTORIAL TINYINT
)
BEGIN
    DECLARE V_PASSWORD_HASH_ANTERIOR VARCHAR(255);

    SELECT PASSWORD_HASH
    INTO V_PASSWORD_HASH_ANTERIOR
    FROM bbf_usuarios
    WHERE ID_USUARIO = P_ID_USUARIO;

    IF P_GUARDAR_HISTORIAL = 1 THEN
        INSERT INTO bbf_usuario_password_historial (
            ID_USUARIO,
            PASSWORD_HASH
        )
        VALUES (
            P_ID_USUARIO,
            V_PASSWORD_HASH_ANTERIOR
        );
    END IF;

    UPDATE bbf_usuarios
    SET
        PASSWORD_HASH = P_PASSWORD_HASH_NUEVO,
        REQUIERE_CAMBIO_PASSWORD = 0,
        INTENTOS_FALLIDOS = 0,
        FECHA_BLOQUEO = NULL,
        ESTADO = 'ACTIVO'
    WHERE ID_USUARIO = P_ID_USUARIO;

    SELECT ROW_COUNT() AS FILAS_AFECTADAS;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_USUARIOS_CREAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_USUARIOS_CREAR`(
    IN P_ID_EMPLEADO INT,
    IN P_NOMBRE_USUARIO VARCHAR(100),
    IN P_CORREO VARCHAR(150),
    IN P_PASSWORD_HASH VARCHAR(255),
    IN P_TIPO_USUARIO VARCHAR(50),
    IN P_TIPO_AUTENTICACION VARCHAR(50),
    IN P_REQUIERE_CAMBIO_PASSWORD TINYINT,
    IN P_CORREO_VERIFICADO TINYINT
)
BEGIN
    DECLARE V_DOMINIO VARCHAR(150);
    DECLARE V_EXISTE_DOMINIO INT DEFAULT 0;

    SET V_DOMINIO = SUBSTRING_INDEX(P_CORREO, '@', -1);

    IF P_TIPO_AUTENTICACION = 'DOMINIO_EMPRESA' THEN

        SELECT COUNT(*)
        INTO V_EXISTE_DOMINIO
        FROM bbf_dominios_autorizados
        WHERE DOMINIO = V_DOMINIO
          AND ACTIVO = 1;

        IF V_EXISTE_DOMINIO = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El correo no pertenece a un dominio autorizado.';
        END IF;

    END IF;

    INSERT INTO bbf_usuarios (
        ID_EMPLEADO,
        NOMBRE_USUARIO,
        CORREO,
        PASSWORD_HASH,
        TIPO_USUARIO,
        TIPO_AUTENTICACION,
        REQUIERE_CAMBIO_PASSWORD,
        CORREO_VERIFICADO,
        ESTADO
    )
    VALUES (
        P_ID_EMPLEADO,
        P_NOMBRE_USUARIO,
        P_CORREO,
        P_PASSWORD_HASH,
        P_TIPO_USUARIO,
        P_TIPO_AUTENTICACION,
        P_REQUIERE_CAMBIO_PASSWORD,
        P_CORREO_VERIFICADO,
        'ACTIVO'
    );

    SELECT LAST_INSERT_ID() AS ID_USUARIO;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_USUARIOS_CREAR_POR_DOCUMENTO` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_USUARIOS_CREAR_POR_DOCUMENTO`(
    IN P_NUMERO_DOCUMENTO VARCHAR(50),
    IN P_NOMBRE_USUARIO VARCHAR(100),
    IN P_CORREO VARCHAR(150),
    IN P_PASSWORD_HASH VARCHAR(255),
    IN P_TIPO_USUARIO VARCHAR(50),
    IN P_TIPO_AUTENTICACION VARCHAR(50),
    IN P_REQUIERE_CAMBIO_PASSWORD TINYINT,
    IN P_CORREO_VERIFICADO TINYINT
)
BEGIN
    DECLARE V_ID_EMPLEADO INT DEFAULT NULL;
    DECLARE V_DOMINIO VARCHAR(150);
    DECLARE V_EXISTE_DOMINIO INT DEFAULT 0;

    IF P_NUMERO_DOCUMENTO IS NOT NULL AND P_NUMERO_DOCUMENTO <> '' THEN
        SELECT ID_EMPLEADO
        INTO V_ID_EMPLEADO
        FROM bbf_empleados
        WHERE NUMERO_DOCUMENTO = P_NUMERO_DOCUMENTO
        LIMIT 1;

        IF V_ID_EMPLEADO IS NULL THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No existe un empleado con el documento indicado.';
        END IF;
    END IF;

    SET V_DOMINIO = SUBSTRING_INDEX(P_CORREO, '@', -1);

    IF P_TIPO_AUTENTICACION = 'DOMINIO_EMPRESA' THEN
        SELECT COUNT(*)
        INTO V_EXISTE_DOMINIO
        FROM bbf_dominios_autorizados
        WHERE DOMINIO = V_DOMINIO
          AND ACTIVO = 1;

        IF V_EXISTE_DOMINIO = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El correo no pertenece a un dominio autorizado.';
        END IF;
    END IF;

    INSERT INTO bbf_usuarios (
        ID_EMPLEADO,
        NOMBRE_USUARIO,
        CORREO,
        PASSWORD_HASH,
        TIPO_USUARIO,
        TIPO_AUTENTICACION,
        REQUIERE_CAMBIO_PASSWORD,
        CORREO_VERIFICADO,
        ESTADO
    )
    VALUES (
        V_ID_EMPLEADO,
        P_NOMBRE_USUARIO,
        P_CORREO,
        P_PASSWORD_HASH,
        P_TIPO_USUARIO,
        P_TIPO_AUTENTICACION,
        P_REQUIERE_CAMBIO_PASSWORD,
        P_CORREO_VERIFICADO,
        'ACTIVO'
    );

    SELECT LAST_INSERT_ID() AS ID_USUARIO;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_USUARIOS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_USUARIOS_LISTAR`(
    IN P_ESTADO VARCHAR(50),
    IN P_TIPO_USUARIO VARCHAR(50),
    IN P_TEXTO_BUSQUEDA VARCHAR(150)
)
BEGIN
    SELECT
        U.ID_USUARIO,
        U.ID_EMPLEADO,
        U.NOMBRE_USUARIO,
        U.CORREO,
        U.TIPO_USUARIO,
        U.TIPO_AUTENTICACION,
        U.REQUIERE_CAMBIO_PASSWORD,
        U.CORREO_VERIFICADO,
        U.ESTADO,
        U.ULTIMO_LOGIN,
        U.CREATED_AT,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS) AS NOMBRE_COMPLETO
    FROM bbf_usuarios U
    LEFT JOIN bbf_empleados E ON E.ID_EMPLEADO = U.ID_EMPLEADO
    WHERE
        U.ESTADO <> 'ELIMINADO'
        AND (P_ESTADO IS NULL OR P_ESTADO = '' OR U.ESTADO = P_ESTADO)
        AND (P_TIPO_USUARIO IS NULL OR P_TIPO_USUARIO = '' OR U.TIPO_USUARIO = P_TIPO_USUARIO)
        AND (
            P_TEXTO_BUSQUEDA IS NULL
            OR P_TEXTO_BUSQUEDA = ''
            OR U.NOMBRE_USUARIO LIKE CONCAT('%', P_TEXTO_BUSQUEDA, '%')
            OR U.CORREO LIKE CONCAT('%', P_TEXTO_BUSQUEDA, '%')
            OR E.NOMBRES LIKE CONCAT('%', P_TEXTO_BUSQUEDA, '%')
            OR E.APELLIDOS LIKE CONCAT('%', P_TEXTO_BUSQUEDA, '%')
        )
    ORDER BY U.CREATED_AT DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_USUARIOS_OBTENER_POR_ID` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_USUARIOS_OBTENER_POR_ID`(
    IN P_ID_USUARIO INT
)
BEGIN
    SELECT
        U.ID_USUARIO,
        U.ID_EMPLEADO,
        U.NOMBRE_USUARIO,
        U.CORREO,
        U.TIPO_USUARIO,
        U.TIPO_AUTENTICACION,
        U.REQUIERE_CAMBIO_PASSWORD,
        U.CORREO_VERIFICADO,
        U.ESTADO,
        U.INTENTOS_FALLIDOS,
        U.FECHA_BLOQUEO,
        U.ULTIMO_LOGIN,
        U.CREATED_AT,
        U.UPDATED_AT,
        E.NOMBRES,
        E.APELLIDOS,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS) AS NOMBRE_COMPLETO
    FROM bbf_usuarios U
    LEFT JOIN bbf_empleados E ON E.ID_EMPLEADO = U.ID_EMPLEADO
    WHERE U.ID_USUARIO = P_ID_USUARIO;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_USUARIO_OBTENER_PERMISOS` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_USUARIO_OBTENER_PERMISOS`(
    IN P_ID_USUARIO INT
)
BEGIN
    SELECT DISTINCT
        P.ID_PERMISO,
        P.CODIGO,
        P.NOMBRE,
        P.DESCRIPCION,
        P.MODULO
    FROM bbf_usuario_roles UR
    INNER JOIN bbf_roles R ON R.ID_ROL = UR.ID_ROL
    INNER JOIN bbf_rol_permisos RP ON RP.ID_ROL = R.ID_ROL
    INNER JOIN bbf_permisos P ON P.ID_PERMISO = RP.ID_PERMISO
    WHERE UR.ID_USUARIO = P_ID_USUARIO
      AND R.ACTIVO = 1
      AND P.ACTIVO = 1
    ORDER BY P.MODULO ASC, P.CODIGO ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_USUARIO_OBTENER_ROLES` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_USUARIO_OBTENER_ROLES`(
    IN P_ID_USUARIO INT
)
BEGIN
    SELECT
        R.ID_ROL,
        R.NOMBRE,
        R.DESCRIPCION,
        R.ACTIVO
    FROM bbf_usuario_roles UR
    INNER JOIN bbf_roles R ON R.ID_ROL = UR.ID_ROL
    WHERE UR.ID_USUARIO = P_ID_USUARIO
      AND R.ACTIVO = 1
    ORDER BY R.NOMBRE ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_USUARIO_ROLES_ASIGNAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_USUARIO_ROLES_ASIGNAR`(
    IN P_ID_USUARIO INT,
    IN P_ID_ROL INT
)
BEGIN
    INSERT IGNORE INTO bbf_usuario_roles (
        ID_USUARIO,
        ID_ROL
    )
    VALUES (
        P_ID_USUARIO,
        P_ID_ROL
    );

    SELECT ROW_COUNT() AS FILAS_AFECTADAS;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_USUARIO_ROLES_QUITAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_USUARIO_ROLES_QUITAR`(
    IN P_ID_USUARIO INT,
    IN P_ID_ROL INT
)
BEGIN
    DELETE FROM bbf_usuario_roles
    WHERE ID_USUARIO = P_ID_USUARIO
      AND ID_ROL = P_ID_ROL;

    SELECT ROW_COUNT() AS FILAS_AFECTADAS;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_USUARIO_SESIONES_CREAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_USUARIO_SESIONES_CREAR`(
    IN P_ID_USUARIO INT,
    IN P_REFRESH_TOKEN_HASH VARCHAR(255),
    IN P_IP_ORIGEN VARCHAR(50),
    IN P_USER_AGENT VARCHAR(500),
    IN P_FECHA_EXPIRACION DATETIME
)
BEGIN
    INSERT INTO bbf_usuario_sesiones (
        ID_USUARIO,
        REFRESH_TOKEN_HASH,
        IP_ORIGEN,
        USER_AGENT,
        FECHA_EXPIRACION,
        ACTIVO
    )
    VALUES (
        P_ID_USUARIO,
        P_REFRESH_TOKEN_HASH,
        P_IP_ORIGEN,
        P_USER_AGENT,
        P_FECHA_EXPIRACION,
        1
    );

    SELECT LAST_INSERT_ID() AS ID_SESION;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_USUARIO_SESIONES_OBTENER_POR_TOKEN` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_USUARIO_SESIONES_OBTENER_POR_TOKEN`(
    IN P_REFRESH_TOKEN_HASH VARCHAR(255)
)
BEGIN
    SELECT
        S.ID_SESION,
        S.ID_USUARIO,
        S.REFRESH_TOKEN_HASH,
        S.IP_ORIGEN,
        S.USER_AGENT,
        S.FECHA_CREACION,
        S.FECHA_EXPIRACION,
        S.FECHA_REVOCACION,
        S.ACTIVO,
        U.CORREO,
        U.NOMBRE_USUARIO,
        U.TIPO_USUARIO,
        U.ESTADO
    FROM bbf_usuario_sesiones S
    INNER JOIN bbf_usuarios U ON U.ID_USUARIO = S.ID_USUARIO
    WHERE S.REFRESH_TOKEN_HASH = P_REFRESH_TOKEN_HASH
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_USUARIO_SESIONES_REVOCAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_USUARIO_SESIONES_REVOCAR`(
    IN P_ID_SESION BIGINT
)
BEGIN
    UPDATE bbf_usuario_sesiones
    SET
        ACTIVO = 0,
        FECHA_REVOCACION = CURRENT_TIMESTAMP
    WHERE ID_SESION = P_ID_SESION
      AND ACTIVO = 1;

    SELECT ROW_COUNT() AS FILAS_AFECTADAS;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_USUARIO_SESIONES_REVOCAR_TODAS` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BBF_USUARIO_SESIONES_REVOCAR_TODAS`(
    IN P_ID_USUARIO INT
)
BEGIN
    UPDATE bbf_usuario_sesiones
    SET
        ACTIVO = 0,
        FECHA_REVOCACION = CURRENT_TIMESTAMP
    WHERE ID_USUARIO = P_ID_USUARIO
      AND ACTIVO = 1;

    SELECT ROW_COUNT() AS FILAS_AFECTADAS;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-08-11 12:00:52
