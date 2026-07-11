-- MySQL dump 10.13  Distrib 8.0.45, for Win64 (x86_64)
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
-- ================================================================
-- AJUSTE PARA QA
-- Esquema destino: local
-- Elimina variantes antiguas en MAYÚSCULAS antes de recrear las
-- tablas canónicas en minúsculas.
-- ================================================================
USE `local`;
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `BBF_AREAS`;
DROP TABLE IF EXISTS `BBF_ASPIRANTE_DOCUMENTOS`;
DROP TABLE IF EXISTS `BBF_ASPIRANTE_ESTADO_HISTORIAL`;
DROP TABLE IF EXISTS `BBF_ASPIRANTES`;
DROP TABLE IF EXISTS `BBF_CARGOS`;
DROP TABLE IF EXISTS `BBF_CONTRATO_PLANTILLAS`;
DROP TABLE IF EXISTS `BBF_DOMINIOS_AUTORIZADOS`;
DROP TABLE IF EXISTS `BBF_DOTACION_ENTREGA_DETALLE`;
DROP TABLE IF EXISTS `BBF_DOTACION_ENTREGAS`;
DROP TABLE IF EXISTS `BBF_EMPLEADO_CONTACTO_EMERGENCIA`;
DROP TABLE IF EXISTS `BBF_EMPLEADO_CONTRATOS`;
DROP TABLE IF EXISTS `BBF_EMPLEADO_DOCUMENTOS`;
DROP TABLE IF EXISTS `BBF_EMPLEADO_DOTACION_TALLAS`;
DROP TABLE IF EXISTS `BBF_EMPLEADO_EXAMENES_MEDICOS`;
DROP TABLE IF EXISTS `BBF_EMPLEADO_FICHA_INGRESO`;
DROP TABLE IF EXISTS `BBF_EMPLEADO_SEGURIDAD_SOCIAL`;
DROP TABLE IF EXISTS `BBF_EMPLEADOS`;
DROP TABLE IF EXISTS `BBF_ENTIDADES_SEGURIDAD_SOCIAL`;
DROP TABLE IF EXISTS `BBF_LOG_AUDITORIA`;
DROP TABLE IF EXISTS `BBF_PERMISOS`;
DROP TABLE IF EXISTS `BBF_ROL_PERMISOS`;
DROP TABLE IF EXISTS `BBF_ROLES`;
DROP TABLE IF EXISTS `BBF_TALLAS_DOTACION`;
DROP TABLE IF EXISTS `BBF_TIPOS_CONTRATO`;
DROP TABLE IF EXISTS `BBF_TIPOS_DOCUMENTO`;
DROP TABLE IF EXISTS `BBF_TIPOS_DOCUMENTO_LABORAL`;
DROP TABLE IF EXISTS `BBF_TIPOS_DOTACION`;
DROP TABLE IF EXISTS `BBF_TIPOS_EXAMEN_MEDICO`;
DROP TABLE IF EXISTS `BBF_USUARIO_PASSWORD_HISTORIAL`;
DROP TABLE IF EXISTS `BBF_USUARIO_PASSWORD_RESET`;
DROP TABLE IF EXISTS `BBF_USUARIO_ROLES`;
DROP TABLE IF EXISTS `BBF_USUARIO_SESIONES`;
DROP TABLE IF EXISTS `BBF_USUARIOS`;
-- Fin de limpieza de variantes antiguas.


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
INSERT INTO `bbf_areas` VALUES (1,'QA Area Empleados','Validacion empleados',1,'2026-06-22 22:43:58',NULL),(2,'Administración','Área administrativa general',1,'2026-06-23 10:00:15',NULL),(3,'Recursos Humanos','Gestión administrativa y laboral del personal',1,'2026-06-23 10:00:15',NULL),(4,'Producción','Área operativa de cultivo y producción',1,'2026-06-23 10:00:15',NULL),(5,'Cultivo','Labores de cultivo, siembra, corte y mantenimiento',1,'2026-06-23 10:00:15',NULL),(6,'Poscosecha','Clasificación, empaque y manejo posterior al corte',1,'2026-06-23 10:00:15',NULL),(7,'Ventas','Gestión comercial y atención de clientes',1,'2026-06-23 10:00:15',NULL),(8,'Calidad','Control de calidad del producto y procesos',1,'2026-06-23 10:00:15',NULL),(9,'Logística','Despachos, transporte y coordinación operativa',1,'2026-06-23 10:00:15',NULL),(10,'Mantenimiento','Mantenimiento de infraestructura, equipos y herramientas',1,'2026-06-23 10:00:15',NULL),(11,'Sistemas','Soporte tecnológico y administración de sistemas',1,'2026-06-23 10:00:15',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_aspirante_documentos`
--

LOCK TABLES `bbf_aspirante_documentos` WRITE;
/*!40000 ALTER TABLE `bbf_aspirante_documentos` DISABLE KEYS */;
INSERT INTO `bbf_aspirante_documentos` VALUES (1,1,2,'HojaDeVida',NULL,'https://lavega-cundinamarca.gov.co/Ciudadanos/RepositorioPQRD/Prueba%20Hoja%20de%20Vida.pdf',NULL,NULL,NULL,'CARGADO',NULL,8,0,'2026-06-24 15:02:30',NULL),(2,1,1,'Documento de identidad',NULL,'https://tulua.gov.co/loader.php?lServicio=Tools2&lTipo=descargas&lFuncion=visorpdf&file=https%3A%2F%2Ftulua.gov.co%2Floader.php%3FlServicio%3DTools2%26lTipo%3Ddescargas%26lFuncion%3DexposeDocument%26idFile%3D11850%26tmp%3D892a149f083b3f6cf071648d2f7f6f39%26urlDeleteFunction%3Dhttps%253A%252F%252Ftulua.gov.co%252Floader.php%253FlServicio%253DTools2%2526lTipo%253Ddescargas%2526lFuncion%253DdeleteTemporalFile%2526tmp%253D892a149f083b3f6cf071648d2f7f6f39&pdf=1&tmp=892a149f083b3f6cf071648d2f7f6f39&fi',NULL,NULL,NULL,'CARGADO',NULL,8,0,'2026-06-24 15:07:09',NULL),(3,1,2,'HV','HV 2026.pdf',NULL,'uploads/applicants/1/documents/20260629_164906_hv-2026.pdf','application/pdf',151598,'CARGADO','Fisica',8,0,'2026-06-29 11:49:06',NULL),(4,2,2,'HV','260624 - RRHH.pdf',NULL,'uploads/applicants/2/documents/20260709_204222_260624-rrhh.pdf','application/pdf',148489,'CARGADO','NA',8,0,'2026-07-09 15:42:22',NULL),(5,2,1,'CC',NULL,'https://urleterna.com',NULL,NULL,NULL,'CARGADO','NA',8,0,'2026-07-09 15:43:06',NULL),(6,5,2,'hv carla','PDF test.pdf',NULL,'uploads/applicants/5/documents/20260710_173819_pdf-test.pdf','application/pdf',1196047,'CARGADO','test',8,0,'2026-07-10 12:38:19',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_aspirante_estado_historial`
--

LOCK TABLES `bbf_aspirante_estado_historial` WRITE;
/*!40000 ALTER TABLE `bbf_aspirante_estado_historial` DISABLE KEYS */;
INSERT INTO `bbf_aspirante_estado_historial` VALUES (1,1,NULL,'REGISTRADO','Registro inicial del aspirante',8,'2026-06-24 14:22:17'),(2,2,NULL,'REGISTRADO','Registro inicial del aspirante',8,'2026-07-09 15:41:36'),(3,2,'REGISTRADO','APROBADO_CONTRATACION','Aprobado por superAD para iniciar contratacion',8,'2026-07-09 15:44:33'),(4,2,'APROBADO_CONTRATACION','CONVERTIDO_EMPLEADO','Conversion a empleado',8,'2026-07-09 15:45:18'),(5,3,NULL,'REGISTRADO','Registro inicial del aspirante',8,'2026-07-09 16:23:30'),(6,3,'REGISTRADO','APROBADO_CONTRATACION','Aprobado por RRHH para iniciar contratacion',8,'2026-07-09 16:23:36'),(7,3,'APROBADO_CONTRATACION','CONVERTIDO_EMPLEADO','Conversion a empleado',8,'2026-07-09 16:23:46'),(8,4,NULL,'REGISTRADO','Registro inicial del aspirante',8,'2026-07-09 17:34:20'),(9,4,'REGISTRADO','APROBADO_CONTRATACION','Aprobado por SUPER AD para iniciar contratacion',8,'2026-07-09 17:34:40'),(10,4,'APROBADO_CONTRATACION','APROBADO_CONTRATACION','Aprobado por SUPER AD para iniciar contratacion',8,'2026-07-09 17:34:43'),(11,4,'APROBADO_CONTRATACION','CONVERTIDO_EMPLEADO','Conversion a empleado',8,'2026-07-09 17:34:53'),(12,5,NULL,'REGISTRADO','Registro inicial del aspirante',8,'2026-07-10 12:37:06'),(13,5,'REGISTRADO','APROBADO_CONTRATACION','Aprobado por admin',8,'2026-07-10 12:39:05'),(14,5,'APROBADO_CONTRATACION','APROBADO_CONTRATACION','Aprobado por admin',8,'2026-07-10 12:39:08'),(15,5,'APROBADO_CONTRATACION','CONVERTIDO_EMPLEADO','Conversion a empleado',8,'2026-07-10 12:39:27');
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
  `LUGAR_NACIMIENTO` varchar(150) DEFAULT NULL,
  `DEPARTAMENTO_NACIMIENTO` varchar(150) DEFAULT NULL,
  `NACIONALIDAD` varchar(100) DEFAULT NULL,
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
  CONSTRAINT `FK_BBF_ASPIRANTES_AREA` FOREIGN KEY (`ID_AREA_ASPIRA`) REFERENCES `bbf_areas` (`ID_AREA`),
  CONSTRAINT `FK_BBF_ASPIRANTES_CARGO` FOREIGN KEY (`ID_CARGO_ASPIRA`) REFERENCES `bbf_cargos` (`ID_CARGO`),
  CONSTRAINT `FK_BBF_ASPIRANTES_EMPLEADO_GENERADO` FOREIGN KEY (`ID_EMPLEADO_GENERADO`) REFERENCES `bbf_empleados` (`ID_EMPLEADO`),
  CONSTRAINT `FK_BBF_ASPIRANTES_TIPO_DOCUMENTO` FOREIGN KEY (`ID_TIPO_DOCUMENTO`) REFERENCES `bbf_tipos_documento` (`ID_TIPO_DOCUMENTO`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_aspirantes`
--

LOCK TABLES `bbf_aspirantes` WRITE;
/*!40000 ALTER TABLE `bbf_aspirantes` DISABLE KEYS */;
INSERT INTO `bbf_aspirantes` VALUES (1,2,'260621','Ricardo','Cardenas','GC@gmail.com','3216598741','Cale falsa 123','2005-01-13','Bogota D.C',NULL,'Colmbiana',NULL,NULL,NULL,NULL,0,0,5,8,'REGISTRADO',NULL,NULL,0,'2026-06-24 14:22:16',NULL),(2,2,'2607091','Valeria','Jimenez','VJ@email.com','3216549874','Calle','2007-06-06','Zipaquira',NULL,'Colombiana',NULL,NULL,NULL,NULL,0,0,4,3,'CONVERTIDO_EMPLEADO','NA',10,0,'2026-07-09 15:41:36','2026-07-09 15:45:18'),(3,2,'2607092','Alejandro','Villalva','AV@email.com','3216545987','Calle 4','2002-06-04','Zipaquira',NULL,'Colombiana',NULL,NULL,NULL,NULL,0,0,11,11,'CONVERTIDO_EMPLEADO','NA',11,0,'2026-07-09 16:23:30','2026-07-09 16:23:46'),(4,2,'260791','Guillermo','Vargas','GV@email.com','3215487963','Calle 44','2003-06-19','Bogota','Bogota','Colombiana','Zipaquira','Cundinamarca','CASADO','PROFESIONAL',3,2,5,5,'CONVERTIDO_EMPLEADO','Na',12,0,'2026-07-09 17:34:20','2026-07-09 17:34:53'),(5,2,'1075689456','carla','sanchez','carla@gmail.com','325365458','calle4#6-24','1996-05-20','chiquinmquira','boyaca','colombiana','zipaquira','cundinamarca','SOLTERO','PROFESIONAL',2,2,2,3,'CONVERTIDO_EMPLEADO','test',13,0,'2026-07-10 12:37:06','2026-07-10 12:39:27');
/*!40000 ALTER TABLE `bbf_aspirantes` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_cargos`
--

LOCK TABLES `bbf_cargos` WRITE;
/*!40000 ALTER TABLE `bbf_cargos` DISABLE KEYS */;
INSERT INTO `bbf_cargos` VALUES (1,'QA Cargo Inicial','Validacion empleados',1,'2026-06-22 22:43:58',NULL),(2,'QA Cargo Editado','Validacion empleados',1,'2026-06-22 22:43:58',NULL),(3,'Administrador','Responsable de la administración general del sistema o empresa',1,'2026-06-23 10:00:15',NULL),(4,'Auxiliar de Recursos Humanos','Apoyo en procesos administrativos de personal',1,'2026-06-23 10:00:15',NULL),(5,'Jefe de Recursos Humanos','Responsable del área de talento humano',1,'2026-06-23 10:00:15',NULL),(6,'Supervisor','Responsable de supervisión de personal y procesos',1,'2026-06-23 10:00:15',NULL),(7,'Supervisor de Calidad','Responsable de control y seguimiento de calidad',1,'2026-06-23 10:00:15',NULL),(8,'Operario','Personal operativo general',1,'2026-06-23 10:00:15',NULL),(9,'Operario de Cultivo','Personal encargado de labores de cultivo',1,'2026-06-23 10:00:15',NULL),(10,'Operario de Poscosecha','Personal encargado de labores de poscosecha',1,'2026-06-23 10:00:15',NULL),(11,'Vendedor','Responsable de gestión comercial y clientes',1,'2026-06-23 10:00:15',NULL),(12,'Auxiliar Administrativo','Apoyo en tareas administrativas',1,'2026-06-23 10:00:15',NULL),(13,'Conductor','Responsable de transporte y entregas',1,'2026-06-23 10:00:15',NULL),(14,'Técnico de Mantenimiento','Responsable de mantenimiento de equipos e infraestructura',1,'2026-06-23 10:00:15',NULL);
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
-- Table structure for table `bbf_dotacion_entrega_detalle`
--

DROP TABLE IF EXISTS `bbf_dotacion_entrega_detalle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbf_dotacion_entrega_detalle` (
  `ID_DOTACION_ENTREGA_DETALLE` int(11) NOT NULL AUTO_INCREMENT,
  `ID_DOTACION_ENTREGA` int(11) NOT NULL,
  `ID_TIPO_DOTACION` int(11) NOT NULL,
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
  CONSTRAINT `FK_BBF_DOT_DET_ELIMINADO_POR` FOREIGN KEY (`ID_ELIMINADO_POR`) REFERENCES `bbf_usuarios` (`ID_USUARIO`),
  CONSTRAINT `FK_BBF_DOT_DET_ENTREGA` FOREIGN KEY (`ID_DOTACION_ENTREGA`) REFERENCES `bbf_dotacion_entregas` (`ID_DOTACION_ENTREGA`) ON DELETE CASCADE,
  CONSTRAINT `FK_BBF_DOT_DET_TALLA` FOREIGN KEY (`ID_TALLA_DOTACION`) REFERENCES `bbf_tallas_dotacion` (`ID_TALLA_DOTACION`),
  CONSTRAINT `FK_BBF_DOT_DET_TIPO` FOREIGN KEY (`ID_TIPO_DOTACION`) REFERENCES `bbf_tipos_dotacion` (`ID_TIPO_DOTACION`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_dotacion_entrega_detalle`
--

LOCK TABLES `bbf_dotacion_entrega_detalle` WRITE;
/*!40000 ALTER TABLE `bbf_dotacion_entrega_detalle` DISABLE KEYS */;
INSERT INTO `bbf_dotacion_entrega_detalle` VALUES (1,1,3,36,1,NULL,0,NULL,NULL,'2026-06-23 11:58:00'),(2,1,4,54,2,NULL,0,NULL,NULL,'2026-06-23 11:58:00'),(3,2,4,50,3,NULL,0,NULL,NULL,'2026-06-23 12:00:07'),(4,3,6,15,2,'me falto el blanco',0,NULL,NULL,'2026-06-23 18:15:06'),(5,4,3,32,2,NULL,0,NULL,NULL,'2026-06-23 22:09:11'),(6,4,1,1,2,NULL,0,NULL,NULL,'2026-06-23 22:09:11'),(7,4,7,6,2,NULL,0,NULL,NULL,'2026-06-23 22:09:11'),(8,4,6,15,2,NULL,0,NULL,NULL,'2026-06-23 22:09:11'),(9,4,5,53,3,NULL,0,NULL,NULL,'2026-06-23 22:09:11'),(10,4,4,54,1,'entrega temporal',0,NULL,NULL,'2026-06-23 22:09:11'),(11,4,2,16,1,NULL,0,NULL,NULL,'2026-06-23 22:09:11');
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
  `FECHA_CONFIRMACION` datetime DEFAULT NULL,
  `ESTADO` enum('REGISTRADA','ENTREGADA','ANULADA') NOT NULL DEFAULT 'REGISTRADA',
  `ELIMINADO` tinyint(1) NOT NULL DEFAULT 0,
  `FECHA_ELIMINACION` datetime DEFAULT NULL,
  `ID_ELIMINADO_POR` int(11) DEFAULT NULL,
  `MOTIVO_ELIMINACION` varchar(500) DEFAULT NULL,
  `OBSERVACIONES` text DEFAULT NULL,
  `OBSERVACION_CONFIRMACION` varchar(500) DEFAULT NULL,
  `FIRMA_URL` varchar(500) DEFAULT NULL,
  `ID_REGISTRADO_POR` int(11) DEFAULT NULL,
  `ID_CONFIRMADO_POR` int(11) DEFAULT NULL,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_DOTACION_ENTREGA`),
  KEY `FK_BBF_DOT_ENTREGAS_EMPLEADO` (`ID_EMPLEADO`),
  KEY `FK_BBF_DOT_ENTREGAS_USUARIO` (`ID_REGISTRADO_POR`),
  KEY `FK_BBF_DOT_ENTREGAS_CONFIRMADO_POR` (`ID_CONFIRMADO_POR`),
  KEY `FK_BBF_DOT_ENTREGAS_ELIMINADO_POR` (`ID_ELIMINADO_POR`),
  CONSTRAINT `FK_BBF_DOT_ENTREGAS_CONFIRMADO_POR` FOREIGN KEY (`ID_CONFIRMADO_POR`) REFERENCES `bbf_usuarios` (`ID_USUARIO`),
  CONSTRAINT `FK_BBF_DOT_ENTREGAS_ELIMINADO_POR` FOREIGN KEY (`ID_ELIMINADO_POR`) REFERENCES `bbf_usuarios` (`ID_USUARIO`),
  CONSTRAINT `FK_BBF_DOT_ENTREGAS_EMPLEADO` FOREIGN KEY (`ID_EMPLEADO`) REFERENCES `bbf_empleados` (`ID_EMPLEADO`),
  CONSTRAINT `FK_BBF_DOT_ENTREGAS_USUARIO` FOREIGN KEY (`ID_REGISTRADO_POR`) REFERENCES `bbf_usuarios` (`ID_USUARIO`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_dotacion_entregas`
--

LOCK TABLES `bbf_dotacion_entregas` WRITE;
/*!40000 ALTER TABLE `bbf_dotacion_entregas` DISABLE KEYS */;
INSERT INTO `bbf_dotacion_entregas` VALUES (1,6,'2026-06-23','2026-06-23 20:34:21','ENTREGADA',0,NULL,NULL,NULL,'Se entrega dotación','Recibido en buen estado',NULL,8,13,'2026-06-23 11:58:00','2026-06-23 20:34:21'),(2,6,'2026-06-23',NULL,'REGISTRADA',0,NULL,NULL,NULL,NULL,NULL,NULL,8,NULL,'2026-06-23 12:00:07',NULL),(3,6,'2026-06-23',NULL,'REGISTRADA',0,NULL,NULL,NULL,NULL,NULL,NULL,8,NULL,'2026-06-23 18:15:06',NULL),(4,7,'2026-06-24','2026-06-23 22:09:56','ENTREGADA',0,NULL,NULL,NULL,'Entrega de dotación completa','Recibí en buen estado la dotación completa, pendiente cambio de guantes',NULL,8,14,'2026-06-23 22:09:11','2026-06-23 22:09:56');
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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_empleado_contacto_emergencia`
--

LOCK TABLES `bbf_empleado_contacto_emergencia` WRITE;
/*!40000 ALTER TABLE `bbf_empleado_contacto_emergencia` DISABLE KEYS */;
INSERT INTO `bbf_empleado_contacto_emergencia` VALUES (1,6,'Ana Jimenez','Tia','9874585','3194488753','Calle 35 # 58 - 98','No llamar en caso de emergencia',0,'2026-06-24 01:25:15',NULL),(2,12,'Marley Nandez','Prima','3114578951','3215487951','Calle 54 # 95 - 25','NA',0,'2026-07-09 19:04:02',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_empleado_contratos`
--

LOCK TABLES `bbf_empleado_contratos` WRITE;
/*!40000 ALTER TABLE `bbf_empleado_contratos` DISABLE KEYS */;
INSERT INTO `bbf_empleado_contratos` VALUES (1,6,4,NULL,2,13,'2026-06-01','2026-06-30',3,1400000.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Completa',30,'ACTIVO','https:drive.com','NA',8,0,'2026-06-24 01:26:04',NULL),(2,8,1,NULL,1,1,'2026-06-24',NULL,NULL,1423500.00,1,'QUINCENAL','VEREDA SAN JOSE, FINCA BARRO BLANCO','BBTH-TEST-001','ADMINISTRATIVO',NULL,NULL,'Funciones administrativas relacionadas con el cargo.','44 horas semanales',60,'ACTIVO',NULL,'Contrato de prueba registrado desde SP.',1,0,'2026-06-24 09:57:29',NULL),(3,12,4,2,5,8,'2026-07-10','2026-08-09',NULL,2000000.00,1,'MENSUAL','VEREDA SAN JOSE, FINCA BARRO BLANCO','1','OPERATIVO','Realizar labores relacionadas con floricultura.',5,'Funciones expecificasa a llevar a cabo','44 horas semanales efectivas de labor',NULL,'ACTIVO','generated-contracts/3/contrato-3-260791-20260710-023711.pdf','NA',8,0,'2026-07-09 19:10:09','2026-07-09 21:37:12'),(4,12,3,1,8,8,'2026-07-10','2026-08-09',3,2000000.00,0,'MENSUAL','VEREDA SAN JOSE, FINCA BARRO BLANCO','2','ADMINISTRATIVO',NULL,NULL,'funciones','44 horas semanales efectivas de labor',60,'ACTIVO','generated-contracts/4/contrato-4-260791-20260710-022342-awodcc.docx',NULL,8,0,'2026-07-09 19:12:23','2026-07-09 21:23:42'),(5,12,2,3,2,12,'2026-07-10',NULL,NULL,2000000.00,1,'MENSUAL','FINCA BARRO BLANCO GACHANCIPA','3','ADMINISTRATIVO',NULL,NULL,NULL,'44 horas semanales efectivas de labor',60,'ACTIVO','generated-contracts/5/contrato-5-260791-20260710-024438.pdf',NULL,8,0,'2026-07-09 19:13:16','2026-07-09 21:44:41'),(6,13,2,3,2,3,'2026-07-10',NULL,NULL,2000000.00,0,'MENSUAL','FINCA BARRO BLANCO GACHANCIPA','1','ADMINISTRATIVO',NULL,NULL,NULL,'44 horas semanales efectivas de labor',60,'ACTIVO',NULL,NULL,8,0,'2026-07-10 12:40:29',NULL);
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
  `ID_TIPO_DOCUMENTO_LABORAL` int(11) NOT NULL,
  `NOMBRE_ARCHIVO` varchar(255) NOT NULL,
  `ARCHIVO_URL` varchar(500) NOT NULL,
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
  CONSTRAINT `FK_BBF_DOCS_CARGADO_POR` FOREIGN KEY (`ID_CARGADO_POR`) REFERENCES `bbf_usuarios` (`ID_USUARIO`),
  CONSTRAINT `FK_BBF_DOCS_EMPLEADO` FOREIGN KEY (`ID_EMPLEADO`) REFERENCES `bbf_empleados` (`ID_EMPLEADO`),
  CONSTRAINT `FK_BBF_DOCS_TIPO` FOREIGN KEY (`ID_TIPO_DOCUMENTO_LABORAL`) REFERENCES `bbf_tipos_documento_laboral` (`ID_TIPO_DOCUMENTO_LABORAL`),
  CONSTRAINT `FK_BBF_DOCS_VALIDADO_POR` FOREIGN KEY (`ID_VALIDADO_POR`) REFERENCES `bbf_usuarios` (`ID_USUARIO`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_empleado_documentos`
--

LOCK TABLES `bbf_empleado_documentos` WRITE;
/*!40000 ALTER TABLE `bbf_empleado_documentos` DISABLE KEYS */;
INSERT INTO `bbf_empleado_documentos` VALUES (1,6,1,'segurosocial','NA','98',89,'2026-06-24 01:27:42','2026-06-26','RECHAZADO',NULL,8,NULL,NULL,0,'2026-06-24 01:27:42',NULL),(2,10,2,'HV','','application/pdf',148489,'2026-07-09 15:45:17',NULL,'CARGADO','Documento migrado desde aspirante. NA',8,NULL,NULL,0,'2026-07-09 15:45:17',NULL),(3,10,1,'CC','https://urleterna.com',NULL,NULL,'2026-07-09 15:45:17',NULL,'CARGADO','Documento migrado desde aspirante. NA',8,NULL,NULL,0,'2026-07-09 15:45:17',NULL);
/*!40000 ALTER TABLE `bbf_empleado_documentos` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_empleado_dotacion_tallas`
--

LOCK TABLES `bbf_empleado_dotacion_tallas` WRITE;
/*!40000 ALTER TABLE `bbf_empleado_dotacion_tallas` DISABLE KEYS */;
INSERT INTO `bbf_empleado_dotacion_tallas` VALUES (1,6,3,32,NULL,13,'2026-06-23 11:56:35',NULL),(2,6,1,1,NULL,13,'2026-06-23 11:56:39',NULL),(3,6,7,6,NULL,13,'2026-06-23 11:56:43',NULL),(4,6,6,15,NULL,13,'2026-06-23 11:56:46',NULL),(5,6,5,53,NULL,13,'2026-06-23 11:56:49',NULL),(6,6,4,50,NULL,13,'2026-06-23 11:56:53',NULL),(7,6,2,16,NULL,13,'2026-06-23 11:56:56',NULL),(8,7,3,34,NULL,14,'2026-06-23 21:32:47',NULL),(9,7,1,5,NULL,14,'2026-06-23 21:32:47',NULL),(10,7,6,7,NULL,14,'2026-06-23 21:32:47',NULL),(11,7,7,6,NULL,14,'2026-06-23 21:32:47',NULL),(12,7,5,49,NULL,14,'2026-06-23 21:32:47',NULL),(13,7,4,48,NULL,14,'2026-06-23 21:32:47',NULL),(14,7,2,8,NULL,14,'2026-06-23 21:32:48',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_empleado_examenes_medicos`
--

LOCK TABLES `bbf_empleado_examenes_medicos` WRITE;
/*!40000 ALTER TABLE `bbf_empleado_examenes_medicos` DISABLE KEYS */;
INSERT INTO `bbf_empleado_examenes_medicos` VALUES (1,6,1,'2026-06-24','Compensar','Funcional','2026-06-25','NA',NULL,0,'2026-06-24 01:27:09',NULL);
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
  `FECHA_NACIMIENTO` date DEFAULT NULL,
  `LUGAR_NACIMIENTO` varchar(150) DEFAULT NULL,
  `NACIONALIDAD` varchar(100) DEFAULT NULL,
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
  `ESTADO_FICHA` enum('PENDIENTE','COMPLETA','INCOMPLETA') NOT NULL DEFAULT 'PENDIENTE',
  `OBSERVACIONES` text DEFAULT NULL,
  `ELIMINADO` tinyint(1) NOT NULL DEFAULT 0,
  `CREATED_AT` datetime NOT NULL DEFAULT current_timestamp(),
  `UPDATED_AT` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`ID_FICHA_INGRESO`),
  UNIQUE KEY `UQ_BBF_FICHA_INGRESO_EMPLEADO` (`ID_EMPLEADO`),
  KEY `IDX_BBF_FICHA_INGRESO_EMPLEADO` (`ID_EMPLEADO`),
  CONSTRAINT `FK_BBF_FICHA_INGRESO_EMPLEADO` FOREIGN KEY (`ID_EMPLEADO`) REFERENCES `bbf_empleados` (`ID_EMPLEADO`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_empleado_ficha_ingreso`
--

LOCK TABLES `bbf_empleado_ficha_ingreso` WRITE;
/*!40000 ALTER TABLE `bbf_empleado_ficha_ingreso` DISABLE KEYS */;
INSERT INTO `bbf_empleado_ficha_ingreso` VALUES (1,6,NULL,'Bogota',NULL,'Bogota','Zipaquira','Cundinamarca','CAlle 3 #23 -59','8847574','AG@email.com','SOLTERO','PROFESIONAL',2,1,'COMPLETA','ficha de prueba',0,'2026-06-24 01:25:15',NULL),(2,11,'2002-06-04','Zipaquira','Colombiana',NULL,NULL,NULL,'Calle 4','3216545987','AV@email.com',NULL,NULL,0,0,'INCOMPLETA','Ficha creada automáticamente desde aspirante. NA',0,'2026-07-09 16:23:46',NULL),(3,12,'2003-06-19','Bogota','Colombiana','Bogota','Zipaquira','Cundinamarca','Calle 44','3215487963','GV@email.com','CASADO','PROFESIONAL',3,2,'COMPLETA','Ficha creada automáticamente desde aspirante. Na',0,'2026-07-09 17:34:53','2026-07-09 19:04:02'),(4,13,'1996-05-20','chiquinmquira','colombiana','boyaca','zipaquira','cundinamarca','calle4#6-24','325365458','carla@gmail.com','SOLTERO','PROFESIONAL',2,2,'INCOMPLETA','Ficha creada automáticamente desde aspirante. test',0,'2026-07-10 12:39:27',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_empleado_seguridad_social`
--

LOCK TABLES `bbf_empleado_seguridad_social` WRITE;
/*!40000 ALTER TABLE `bbf_empleado_seguridad_social` DISABLE KEYS */;
INSERT INTO `bbf_empleado_seguridad_social` VALUES (1,6,1,2,1,2,1,'2026-01-01','2026-06-30','2026-06-01','2026-06-09','2026-06-05',NULL,0,'2026-06-24 01:26:46',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_empleados`
--

LOCK TABLES `bbf_empleados` WRITE;
/*!40000 ALTER TABLE `bbf_empleados` DISABLE KEYS */;
INSERT INTO `bbf_empleados` VALUES (1,NULL,1,'DOC-1782186241','QA Nombre Editado','QA Apellido Editado','qa.empleado.editado.1782186241@barroblancofarms.com.co','3111111111',NULL,1,2,1,'2026-06-01',NULL,'ACTIVO','Empleado editado API',1,'2026-06-22 22:44:07','2026-06-22 22:44:02','2026-06-22 22:44:07'),(2,NULL,1,'DUP-1782186241','QA Nombre','QA Apellido','dup1.1782186241@barroblancofarms.com.co','3000000000',NULL,1,1,1,'2026-06-01',NULL,'ACTIVO','Empleado de validacion API',1,'2026-06-22 22:44:05','2026-06-22 22:44:04','2026-06-22 22:44:05'),(3,NULL,1,'FRONT-1782186686','Front Nombre Editado','Front Apellido Editado','front.editado.1782186686@barroblancofarms.com.co','3220000000',NULL,1,2,1,'2026-06-01',NULL,'ACTIVO','Validacion frontend empleados',1,'2026-06-22 22:51:30','2026-06-22 22:51:27','2026-06-22 22:51:30'),(4,NULL,2,'1072708535','Ricardo','CArdenas','r@email.com','3194400951',NULL,NULL,NULL,NULL,'2026-06-22',NULL,'INCAPACITADO',NULL,1,'2026-06-23 10:12:30','2026-06-22 22:54:19','2026-06-23 10:12:30'),(5,NULL,2,'123456789','Juan','Barco','JC@email.com','3194400951',NULL,5,8,4,'2026-06-01',NULL,'ACTIVO','Empleado test',1,'2026-06-23 20:40:07','2026-06-23 10:13:29','2026-06-23 20:40:07'),(6,NULL,2,'2606231','Alfredo','Gomez','ag@email.com','3194578951','/uploads/employees/employee_6_20260623155323.png',8,9,7,'2026-05-31',NULL,'ACTIVO',NULL,0,NULL,'2026-06-23 10:53:23','2026-06-23 10:53:23'),(7,NULL,2,'2606232','Guillermo','Mendez','Gm@email.com','3216549874','/uploads/employees/employee_7_20260624022957.png',8,8,3,'2025-02-04',NULL,'ACTIVO',NULL,0,NULL,'2026-06-23 21:29:56','2026-06-23 21:29:57'),(8,NULL,8,'2606233','Carlos','Agudelo','CA@email.com','3215487963','/uploads/employees/employee_8_20260624031358.png',5,8,6,'2026-01-05','2026-06-25','RETIRADO','Finalización de contrato, no se renovó.',0,NULL,'2026-06-23 22:13:57','2026-06-23 22:14:48'),(9,NULL,2,'2606241','Camilo','Perez','CP@email.com','3215487951','/uploads/employees/employee_9_20260624222050.png',2,3,7,'2026-06-23',NULL,'ACTIVO','User test para ambiente QA',0,NULL,'2026-06-24 17:20:50','2026-06-24 17:20:50'),(10,2,2,'2607091','Valeria','Jimenez','VJ@email.com','3216549874',NULL,4,3,4,'2026-07-09',NULL,'ACTIVO','Empleado generado desde aspirante. Conversion a empleado',0,NULL,'2026-07-09 15:45:17',NULL),(11,3,2,'2607092','Alejandro','Villalva','AV@email.com','3216545987',NULL,11,11,2,'2026-07-09',NULL,'ACTIVO','Empleado generado desde aspirante. Conversion a empleado',0,NULL,'2026-07-09 16:23:46',NULL),(12,4,2,'260791','Guillermo','Vargas','GV@email.com','3215487963',NULL,2,12,2,'2026-07-09',NULL,'ACTIVO','Empleado generado desde aspirante. Conversion a empleado',0,NULL,'2026-07-09 17:34:53','2026-07-09 19:13:16'),(13,5,2,'1075689456','carla','sanchez','carla@gmail.com','325365458',NULL,2,3,2,'2026-07-10',NULL,'ACTIVO','Empleado generado desde aspirante. Conversion a empleado',0,NULL,'2026-07-10 12:39:26','2026-07-10 12:40:29');
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
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_entidades_seguridad_social`
--

LOCK TABLES `bbf_entidades_seguridad_social` WRITE;
/*!40000 ALTER TABLE `bbf_entidades_seguridad_social` DISABLE KEYS */;
INSERT INTO `bbf_entidades_seguridad_social` VALUES (1,'EPS','Nueva EPS',NULL,1,'2026-06-23 22:40:44',NULL),(2,'EPS','Sura EPS',NULL,1,'2026-06-23 22:40:44',NULL),(3,'EPS','Sanitas EPS',NULL,1,'2026-06-23 22:40:44',NULL),(4,'EPS','Compensar EPS',NULL,1,'2026-06-23 22:40:44',NULL),(5,'EPS','Famisanar EPS',NULL,1,'2026-06-23 22:40:44',NULL),(6,'EPS','Coosalud EPS',NULL,1,'2026-06-23 22:40:44',NULL),(7,'ARL','ARL Sura',NULL,1,'2026-06-23 22:40:44',NULL),(8,'ARL','ARL Positiva',NULL,1,'2026-06-23 22:40:44',NULL),(9,'ARL','ARL Colmena',NULL,1,'2026-06-23 22:40:44',NULL),(10,'ARL','ARL AXA Colpatria',NULL,1,'2026-06-23 22:40:44',NULL),(11,'PENSION','Porvenir',NULL,1,'2026-06-23 22:40:44',NULL),(12,'PENSION','Protección',NULL,1,'2026-06-23 22:40:44',NULL),(13,'PENSION','Colpensiones',NULL,1,'2026-06-23 22:40:44',NULL),(14,'PENSION','Skandia',NULL,1,'2026-06-23 22:40:44',NULL),(15,'CESANTIAS','Porvenir Cesantías',NULL,1,'2026-06-23 22:40:44',NULL),(16,'CESANTIAS','Protección Cesantías',NULL,1,'2026-06-23 22:40:44',NULL),(17,'CESANTIAS','Fondo Nacional del Ahorro',NULL,1,'2026-06-23 22:40:44',NULL),(18,'CAJA_COMPENSACION','Comfenalco Valle',NULL,1,'2026-06-23 22:40:44',NULL),(19,'CAJA_COMPENSACION','Comfandi',NULL,1,'2026-06-23 22:40:44',NULL),(20,'CAJA_COMPENSACION','Compensar',NULL,1,'2026-06-23 22:40:44',NULL),(21,'CAJA_COMPENSACION','Cafam',NULL,1,'2026-06-23 22:40:44',NULL);
/*!40000 ALTER TABLE `bbf_entidades_seguridad_social` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=257 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_log_auditoria`
--

LOCK TABLES `bbf_log_auditoria` WRITE;
/*!40000 ALTER TABLE `bbf_log_auditoria` DISABLE KEYS */;
INSERT INTO `bbf_log_auditoria` VALUES (1,1,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',1,NULL,'{\"correo\":\"admin@barroblancofarms.com.co\"}','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 16:02:11'),(2,1,'USUARIOS','CREAR','USUARIO',2,NULL,'{\"id_usuario\":2,\"id_empleado\":null,\"nombre_usuario\":\"bootstrap_validation_user\",\"correo\":\"bootstrap.validation@barroblancofarms.com.co\",\"tipo_usuario\":\"PERSONAL_AUTORIZADO\",\"tipo_autenticacion\":\"LOCAL\",\"requiere_cambio_password\":1,\"correo_verificado\":1,\"estado\":\"ACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":null,\"created_at\":\"2026-06-22 16:02:14\",\"updated_at\":null,\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 16:02:14'),(3,1,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',1,NULL,'{\"correo\":\"admin@barroblancofarms.com.co\"}','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 16:15:10'),(4,1,'AUTENTICACION','CAMBIO_PASSWORD','USUARIO',1,NULL,NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 16:15:12'),(5,1,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',1,NULL,'{\"correo\":\"admin@barroblancofarms.com.co\"}','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 16:15:14'),(6,1,'USUARIOS','CREAR','USUARIO',3,NULL,'{\"id_usuario\":3,\"id_empleado\":null,\"nombre_usuario\":\"frontend_flow_validation\",\"correo\":\"frontend.flow.validation@barroblancofarms.com.co\",\"tipo_usuario\":\"PERSONAL_AUTORIZADO\",\"tipo_autenticacion\":\"LOCAL\",\"requiere_cambio_password\":1,\"correo_verificado\":1,\"estado\":\"ACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":null,\"created_at\":\"2026-06-22 16:15:15\",\"updated_at\":null,\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 16:15:15'),(7,1,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',1,NULL,'{\"correo\":\"admin@barroblancofarms.com.co\"}','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 16:21:31'),(8,1,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',1,NULL,'{\"correo\":\"admin@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 16:35:48'),(9,1,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',1,NULL,'{\"correo\":\"admin@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 16:43:14'),(10,1,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',1,NULL,'{\"correo\":\"admin@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 16:45:08'),(11,1,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',1,NULL,'{\"correo\":\"admin@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 16:45:17'),(12,1,'AUTENTICACION','LOGOUT','USUARIO_SESION',8,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 16:47:23'),(13,1,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',1,NULL,'{\"correo\":\"admin@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 16:47:34'),(14,1,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',1,NULL,'{\"correo\":\"admin@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 16:53:33'),(15,1,'AUTENTICACION','CAMBIO_PASSWORD','USUARIO',1,NULL,NULL,'::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 16:53:36'),(16,1,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',1,NULL,'{\"correo\":\"admin@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 16:53:38'),(17,1,'USUARIOS','CREAR','USUARIO',4,NULL,'{\"id_usuario\":4,\"id_empleado\":null,\"nombre_usuario\":\"admin_flow_validation\",\"correo\":\"admin.flow.validation@barroblancofarms.com.co\",\"tipo_usuario\":\"ADMIN\",\"tipo_autenticacion\":\"LOCAL\",\"requiere_cambio_password\":1,\"correo_verificado\":1,\"estado\":\"ACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":null,\"created_at\":\"2026-06-22 16:53:40\",\"updated_at\":null,\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 16:53:40'),(18,1,'AUTENTICACION','LOGOUT','USUARIO_SESION',10,NULL,NULL,'::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 16:53:41'),(19,1,'AUTENTICACION','LOGOUT','USUARIO_SESION',11,NULL,NULL,'::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 16:53:41'),(20,1,'AUTENTICACION','LOGOUT','USUARIO_SESION',9,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 16:55:58'),(21,1,'AUTENTICACION','LOGIN_FALLIDO','USUARIO',1,NULL,'{\"motivo\":\"PASSWORD_INCORRECTO\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 16:56:10'),(22,1,'AUTENTICACION','LOGIN_FALLIDO','USUARIO',1,NULL,'{\"motivo\":\"PASSWORD_INCORRECTO\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 16:56:46'),(23,1,'AUTENTICACION','LOGIN_FALLIDO','USUARIO',1,NULL,'{\"motivo\":\"PASSWORD_INCORRECTO\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 16:57:40'),(24,1,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',1,NULL,'{\"correo\":\"admin@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 16:59:10'),(25,1,'USUARIOS','CREAR','USUARIO',5,NULL,'{\"id_usuario\":5,\"id_empleado\":null,\"nombre_usuario\":\"Cardenas Empleado\",\"correo\":\"CE@email.com\",\"tipo_usuario\":\"EMPLEADO\",\"tipo_autenticacion\":\"LOCAL\",\"requiere_cambio_password\":0,\"correo_verificado\":0,\"estado\":\"ACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":null,\"created_at\":\"2026-06-22 17:05:11\",\"updated_at\":null,\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 17:05:11'),(26,1,'USUARIOS','CREAR','USUARIO',6,NULL,'{\"id_usuario\":6,\"id_empleado\":null,\"nombre_usuario\":\"Dayana Santafe\",\"correo\":\"RH@barroblancofarms.com.co\",\"tipo_usuario\":\"PERSONAL_AUTORIZADO\",\"tipo_autenticacion\":\"LOCAL\",\"requiere_cambio_password\":1,\"correo_verificado\":0,\"estado\":\"ACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":null,\"created_at\":\"2026-06-22 17:07:10\",\"updated_at\":null,\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 17:07:10'),(27,1,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',1,NULL,'{\"correo\":\"admin@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 17:30:55'),(28,1,'USUARIOS','CREAR','USUARIO',7,NULL,'{\"id_usuario\":7,\"id_empleado\":null,\"nombre_usuario\":\"role_flow_validation\",\"correo\":\"role.flow.validation@barroblancofarms.com.co\",\"tipo_usuario\":\"PERSONAL_AUTORIZADO\",\"tipo_autenticacion\":\"LOCAL\",\"requiere_cambio_password\":0,\"correo_verificado\":1,\"estado\":\"ACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":null,\"created_at\":\"2026-06-22 17:30:58\",\"updated_at\":null,\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 17:30:58'),(29,1,'USUARIOS','ASIGNAR_ROL','USUARIO',7,NULL,'{\"id_rol\":1}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 17:31:00'),(30,1,'USUARIOS','QUITAR_ROL','USUARIO',7,'{\"id_rol\":1}',NULL,'::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 17:31:01'),(31,1,'USUARIOS','ASIGNAR_ROL','USUARIO',7,NULL,'{\"id_rol\":1}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 17:31:02'),(33,1,'AUTENTICACION','LOGOUT','USUARIO_SESION',14,NULL,NULL,'::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 17:31:05'),(35,1,'AUTENTICACION','LOGOUT','USUARIO_SESION',13,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 17:33:24'),(36,1,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',1,NULL,'{\"correo\":\"admin@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 17:34:18'),(37,1,'AUTENTICACION','LOGOUT','USUARIO_SESION',17,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 18:14:40'),(38,1,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',1,NULL,'{\"correo\":\"admin@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 18:18:06'),(39,1,'AUTENTICACION','LOGOUT','USUARIO_SESION',19,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 18:53:30'),(40,1,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',1,NULL,'{\"correo\":\"admin@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 18:54:21'),(41,1,'AUTENTICACION','LOGOUT','USUARIO_SESION',20,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 19:10:19'),(42,1,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',1,NULL,'{\"correo\":\"admin@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 19:11:57'),(43,1,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',1,NULL,'{\"correo\":\"admin@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 19:12:06'),(44,1,'AUTENTICACION','LOGOUT','USUARIO_SESION',22,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 19:18:03'),(45,1,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',1,NULL,'{\"correo\":\"admin@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 19:19:07'),(46,1,'USUARIOS','CREAR','USUARIO',8,NULL,'{\"id_usuario\":8,\"id_empleado\":null,\"nombre_usuario\":\"Super AD\",\"correo\":\"Ad@barroblancofarms.com.co\",\"tipo_usuario\":\"EMPLEADO\",\"tipo_autenticacion\":\"DOMINIO_EMPRESA\",\"requiere_cambio_password\":0,\"correo_verificado\":0,\"estado\":\"ACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":null,\"created_at\":\"2026-06-22 19:28:50\",\"updated_at\":null,\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 19:28:50'),(47,1,'AUTENTICACION','LOGOUT','USUARIO_SESION',23,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 19:30:39'),(48,8,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',8,NULL,'{\"correo\":\"Ad@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 19:30:46'),(49,8,'AUTENTICACION','LOGOUT','USUARIO_SESION',24,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 19:30:53'),(50,1,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',1,NULL,'{\"correo\":\"admin@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 19:31:10'),(51,1,'USUARIOS','ASIGNAR_ROL','USUARIO',8,NULL,'{\"id_rol\":1}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 19:31:34'),(52,1,'AUTENTICACION','LOGOUT','USUARIO_SESION',25,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 19:33:08'),(53,8,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',8,NULL,'{\"correo\":\"Ad@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 19:33:19'),(54,1,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',1,NULL,'{\"correo\":\"admin@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 20:44:16'),(55,1,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',1,NULL,'{\"correo\":\"admin@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 20:45:06'),(56,1,'USUARIOS','CREAR','USUARIO',9,NULL,'{\"id_usuario\":9,\"id_empleado\":null,\"nombre_usuario\":\"qa_user_1782179106\",\"correo\":\"qa.user.1782179106@barroblancofarms.com.co\",\"tipo_usuario\":\"ADMIN\",\"tipo_autenticacion\":\"LOCAL\",\"requiere_cambio_password\":0,\"correo_verificado\":1,\"estado\":\"ACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":null,\"created_at\":\"2026-06-22 20:45:08\",\"updated_at\":null,\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 20:45:08'),(57,1,'USUARIOS','ACTUALIZAR','USUARIO',9,'{\"id_usuario\":9,\"id_empleado\":null,\"nombre_usuario\":\"qa_user_1782179106\",\"correo\":\"qa.user.1782179106@barroblancofarms.com.co\",\"tipo_usuario\":\"ADMIN\",\"tipo_autenticacion\":\"LOCAL\",\"requiere_cambio_password\":0,\"correo_verificado\":1,\"estado\":\"ACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":null,\"created_at\":\"2026-06-22 20:45:08\",\"updated_at\":null,\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','{\"id_usuario\":9,\"id_empleado\":null,\"nombre_usuario\":\"qa_user_1782179106_edit\",\"correo\":\"qa.user.1782179106@barroblancofarms.com.co\",\"tipo_usuario\":\"ADMIN\",\"tipo_autenticacion\":\"LOCAL\",\"requiere_cambio_password\":0,\"correo_verificado\":1,\"estado\":\"ACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":null,\"created_at\":\"2026-06-22 20:45:08\",\"updated_at\":\"2026-06-22 20:45:08\",\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 20:45:08'),(58,1,'USUARIOS','ACTUALIZAR','USUARIO',9,'{\"id_usuario\":9,\"id_empleado\":null,\"nombre_usuario\":\"qa_user_1782179106_edit\",\"correo\":\"qa.user.1782179106@barroblancofarms.com.co\",\"tipo_usuario\":\"ADMIN\",\"tipo_autenticacion\":\"LOCAL\",\"requiere_cambio_password\":0,\"correo_verificado\":1,\"estado\":\"ACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":null,\"created_at\":\"2026-06-22 20:45:08\",\"updated_at\":\"2026-06-22 20:45:08\",\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','{\"id_usuario\":9,\"id_empleado\":null,\"nombre_usuario\":\"qa_user_1782179106_edit\",\"correo\":\"qa.user.1782179106@barroblancofarms.com.co\",\"tipo_usuario\":\"ADMIN\",\"tipo_autenticacion\":\"DOMINIO_EMPRESA\",\"requiere_cambio_password\":0,\"correo_verificado\":1,\"estado\":\"ACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":null,\"created_at\":\"2026-06-22 20:45:08\",\"updated_at\":\"2026-06-22 20:45:09\",\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 20:45:09'),(59,1,'USUARIOS','ASIGNAR_ROL','USUARIO',9,NULL,'{\"id_rol\":2}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 20:45:12'),(60,1,'USUARIOS','QUITAR_ROL','USUARIO',9,'{\"id_rol\":2}',NULL,'::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 20:45:13'),(61,1,'USUARIOS','CAMBIAR_ESTADO','USUARIO',9,'{\"id_usuario\":9,\"id_empleado\":null,\"nombre_usuario\":\"qa_user_1782179106_edit\",\"correo\":\"qa.user.1782179106@barroblancofarms.com.co\",\"tipo_usuario\":\"ADMIN\",\"tipo_autenticacion\":\"DOMINIO_EMPRESA\",\"requiere_cambio_password\":0,\"correo_verificado\":1,\"estado\":\"ACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":null,\"created_at\":\"2026-06-22 20:45:08\",\"updated_at\":\"2026-06-22 20:45:09\",\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','{\"id_usuario\":9,\"id_empleado\":null,\"nombre_usuario\":\"qa_user_1782179106_edit\",\"correo\":\"qa.user.1782179106@barroblancofarms.com.co\",\"tipo_usuario\":\"ADMIN\",\"tipo_autenticacion\":\"DOMINIO_EMPRESA\",\"requiere_cambio_password\":0,\"correo_verificado\":1,\"estado\":\"INACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":null,\"created_at\":\"2026-06-22 20:45:08\",\"updated_at\":\"2026-06-22 20:45:14\",\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 20:45:14'),(62,9,'AUTENTICACION','LOGIN_FALLIDO','USUARIO',9,NULL,'{\"motivo\":\"INACTIVO\"}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 20:45:14'),(63,1,'USUARIOS','CAMBIAR_ESTADO','USUARIO',9,'{\"id_usuario\":9,\"id_empleado\":null,\"nombre_usuario\":\"qa_user_1782179106_edit\",\"correo\":\"qa.user.1782179106@barroblancofarms.com.co\",\"tipo_usuario\":\"ADMIN\",\"tipo_autenticacion\":\"DOMINIO_EMPRESA\",\"requiere_cambio_password\":0,\"correo_verificado\":1,\"estado\":\"INACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":null,\"created_at\":\"2026-06-22 20:45:08\",\"updated_at\":\"2026-06-22 20:45:14\",\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','{\"id_usuario\":9,\"id_empleado\":null,\"nombre_usuario\":\"qa_user_1782179106_edit\",\"correo\":\"qa.user.1782179106@barroblancofarms.com.co\",\"tipo_usuario\":\"ADMIN\",\"tipo_autenticacion\":\"DOMINIO_EMPRESA\",\"requiere_cambio_password\":0,\"correo_verificado\":1,\"estado\":\"ACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":null,\"created_at\":\"2026-06-22 20:45:08\",\"updated_at\":\"2026-06-22 20:45:15\",\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 20:45:15'),(64,9,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',9,NULL,'{\"correo\":\"qa.user.1782179106@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 20:45:15'),(65,1,'USUARIOS','CAMBIAR_ESTADO','USUARIO',9,'{\"id_usuario\":9,\"id_empleado\":null,\"nombre_usuario\":\"qa_user_1782179106_edit\",\"correo\":\"qa.user.1782179106@barroblancofarms.com.co\",\"tipo_usuario\":\"ADMIN\",\"tipo_autenticacion\":\"DOMINIO_EMPRESA\",\"requiere_cambio_password\":0,\"correo_verificado\":1,\"estado\":\"ACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":\"2026-06-22 20:45:15\",\"created_at\":\"2026-06-22 20:45:08\",\"updated_at\":\"2026-06-22 20:45:15\",\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','{\"id_usuario\":9,\"id_empleado\":null,\"nombre_usuario\":\"qa_user_1782179106_edit\",\"correo\":\"qa.user.1782179106@barroblancofarms.com.co\",\"tipo_usuario\":\"ADMIN\",\"tipo_autenticacion\":\"DOMINIO_EMPRESA\",\"requiere_cambio_password\":0,\"correo_verificado\":1,\"estado\":\"INACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":\"2026-06-22 20:45:15\",\"created_at\":\"2026-06-22 20:45:08\",\"updated_at\":\"2026-06-22 20:45:16\",\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 20:45:16'),(66,8,'AUTENTICACION','LOGOUT','USUARIO_SESION',30,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 20:50:43'),(67,8,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',8,NULL,'{\"correo\":\"Ad@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 20:51:15'),(68,8,'USUARIOS','CAMBIAR_ESTADO','USUARIO',1,'{\"id_usuario\":1,\"id_empleado\":null,\"nombre_usuario\":\"admin\",\"correo\":\"admin@barroblancofarms.com.co\",\"tipo_usuario\":\"ADMIN\",\"tipo_autenticacion\":\"LOCAL\",\"requiere_cambio_password\":0,\"correo_verificado\":1,\"estado\":\"ACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":\"2026-06-22 20:45:06\",\"created_at\":\"2026-06-22 16:00:51\",\"updated_at\":\"2026-06-22 20:45:06\",\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','{\"id_usuario\":1,\"id_empleado\":null,\"nombre_usuario\":\"admin\",\"correo\":\"admin@barroblancofarms.com.co\",\"tipo_usuario\":\"ADMIN\",\"tipo_autenticacion\":\"LOCAL\",\"requiere_cambio_password\":0,\"correo_verificado\":1,\"estado\":\"INACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":\"2026-06-22 20:45:06\",\"created_at\":\"2026-06-22 16:00:51\",\"updated_at\":\"2026-06-22 20:54:38\",\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 20:54:38'),(69,8,'USUARIOS','CAMBIAR_ESTADO','USUARIO',1,'{\"id_usuario\":1,\"id_empleado\":null,\"nombre_usuario\":\"admin\",\"correo\":\"admin@barroblancofarms.com.co\",\"tipo_usuario\":\"ADMIN\",\"tipo_autenticacion\":\"LOCAL\",\"requiere_cambio_password\":0,\"correo_verificado\":1,\"estado\":\"INACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":\"2026-06-22 20:45:06\",\"created_at\":\"2026-06-22 16:00:51\",\"updated_at\":\"2026-06-22 20:54:38\",\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','{\"id_usuario\":1,\"id_empleado\":null,\"nombre_usuario\":\"admin\",\"correo\":\"admin@barroblancofarms.com.co\",\"tipo_usuario\":\"ADMIN\",\"tipo_autenticacion\":\"LOCAL\",\"requiere_cambio_password\":0,\"correo_verificado\":1,\"estado\":\"ACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":\"2026-06-22 20:45:06\",\"created_at\":\"2026-06-22 16:00:51\",\"updated_at\":\"2026-06-22 20:54:40\",\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 20:54:40'),(70,8,'USUARIOS','ACTUALIZAR','USUARIO',8,'{\"id_usuario\":8,\"id_empleado\":null,\"nombre_usuario\":\"Super AD\",\"correo\":\"Ad@barroblancofarms.com.co\",\"tipo_usuario\":\"EMPLEADO\",\"tipo_autenticacion\":\"DOMINIO_EMPRESA\",\"requiere_cambio_password\":0,\"correo_verificado\":0,\"estado\":\"ACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":\"2026-06-22 20:51:15\",\"created_at\":\"2026-06-22 19:28:50\",\"updated_at\":\"2026-06-22 20:51:15\",\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','{\"id_usuario\":8,\"id_empleado\":null,\"nombre_usuario\":\"Super AD\",\"correo\":\"Ad@barroblancofarms.com.co\",\"tipo_usuario\":\"ADMIN\",\"tipo_autenticacion\":\"DOMINIO_EMPRESA\",\"requiere_cambio_password\":0,\"correo_verificado\":0,\"estado\":\"ACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":\"2026-06-22 20:51:15\",\"created_at\":\"2026-06-22 19:28:50\",\"updated_at\":\"2026-06-22 21:02:07\",\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 21:02:07'),(71,8,'USUARIOS','CAMBIAR_ESTADO','USUARIO',6,'{\"id_usuario\":6,\"id_empleado\":null,\"nombre_usuario\":\"Dayana Santafe\",\"correo\":\"RH@barroblancofarms.com.co\",\"tipo_usuario\":\"PERSONAL_AUTORIZADO\",\"tipo_autenticacion\":\"LOCAL\",\"requiere_cambio_password\":1,\"correo_verificado\":0,\"estado\":\"ACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":null,\"created_at\":\"2026-06-22 17:07:10\",\"updated_at\":null,\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','{\"id_usuario\":6,\"id_empleado\":null,\"nombre_usuario\":\"Dayana Santafe\",\"correo\":\"RH@barroblancofarms.com.co\",\"tipo_usuario\":\"PERSONAL_AUTORIZADO\",\"tipo_autenticacion\":\"LOCAL\",\"requiere_cambio_password\":1,\"correo_verificado\":0,\"estado\":\"INACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":null,\"created_at\":\"2026-06-22 17:07:10\",\"updated_at\":\"2026-06-22 21:14:44\",\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 21:14:44'),(72,1,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',1,NULL,'{\"correo\":\"admin@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 21:20:40'),(73,1,'USUARIOS','CREAR','USUARIO',10,NULL,'{\"id_usuario\":10,\"id_empleado\":null,\"nombre_usuario\":\"qa_deleted_1782181240\",\"correo\":\"qa.deleted.1782181240@barroblancofarms.com.co\",\"tipo_usuario\":\"ADMIN\",\"tipo_autenticacion\":\"LOCAL\",\"requiere_cambio_password\":0,\"correo_verificado\":1,\"estado\":\"ACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":null,\"created_at\":\"2026-06-22 21:20:41\",\"updated_at\":null,\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 21:20:42'),(74,1,'USUARIOS','CAMBIAR_ESTADO','USUARIO',10,'{\"id_usuario\":10,\"id_empleado\":null,\"nombre_usuario\":\"qa_deleted_1782181240\",\"correo\":\"qa.deleted.1782181240@barroblancofarms.com.co\",\"tipo_usuario\":\"ADMIN\",\"tipo_autenticacion\":\"LOCAL\",\"requiere_cambio_password\":0,\"correo_verificado\":1,\"estado\":\"ACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":null,\"created_at\":\"2026-06-22 21:20:41\",\"updated_at\":null,\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','{\"id_usuario\":10,\"id_empleado\":null,\"nombre_usuario\":\"qa_deleted_1782181240\",\"correo\":\"qa.deleted.1782181240@barroblancofarms.com.co\",\"tipo_usuario\":\"ADMIN\",\"tipo_autenticacion\":\"LOCAL\",\"requiere_cambio_password\":0,\"correo_verificado\":1,\"estado\":\"ELIMINADO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":null,\"created_at\":\"2026-06-22 21:20:41\",\"updated_at\":\"2026-06-22 21:20:42\",\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 21:20:42'),(75,10,'AUTENTICACION','LOGIN_FALLIDO','USUARIO',10,NULL,'{\"motivo\":\"ELIMINADO\"}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 21:20:43'),(76,8,'USUARIOS','CAMBIAR_ESTADO','USUARIO',5,'{\"id_usuario\":5,\"id_empleado\":null,\"nombre_usuario\":\"Cardenas Empleado\",\"correo\":\"CE@email.com\",\"tipo_usuario\":\"EMPLEADO\",\"tipo_autenticacion\":\"LOCAL\",\"requiere_cambio_password\":0,\"correo_verificado\":0,\"estado\":\"ACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":null,\"created_at\":\"2026-06-22 17:05:11\",\"updated_at\":null,\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','{\"id_usuario\":5,\"id_empleado\":null,\"nombre_usuario\":\"Cardenas Empleado\",\"correo\":\"CE@email.com\",\"tipo_usuario\":\"EMPLEADO\",\"tipo_autenticacion\":\"LOCAL\",\"requiere_cambio_password\":0,\"correo_verificado\":0,\"estado\":\"ELIMINADO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":null,\"created_at\":\"2026-06-22 17:05:11\",\"updated_at\":\"2026-06-22 21:27:59\",\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 21:27:59'),(77,8,'USUARIOS','CAMBIAR_ESTADO','USUARIO',9,'{\"id_usuario\":9,\"id_empleado\":null,\"nombre_usuario\":\"qa_user_1782179106_edit\",\"correo\":\"qa.user.1782179106@barroblancofarms.com.co\",\"tipo_usuario\":\"ADMIN\",\"tipo_autenticacion\":\"DOMINIO_EMPRESA\",\"requiere_cambio_password\":0,\"correo_verificado\":1,\"estado\":\"INACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":\"2026-06-22 20:45:15\",\"created_at\":\"2026-06-22 20:45:08\",\"updated_at\":\"2026-06-22 20:45:16\",\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','{\"id_usuario\":9,\"id_empleado\":null,\"nombre_usuario\":\"qa_user_1782179106_edit\",\"correo\":\"qa.user.1782179106@barroblancofarms.com.co\",\"tipo_usuario\":\"ADMIN\",\"tipo_autenticacion\":\"DOMINIO_EMPRESA\",\"requiere_cambio_password\":0,\"correo_verificado\":1,\"estado\":\"ELIMINADO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":\"2026-06-22 20:45:15\",\"created_at\":\"2026-06-22 20:45:08\",\"updated_at\":\"2026-06-22 21:38:25\",\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 21:38:25'),(78,8,'USUARIOS','CAMBIAR_ESTADO','USUARIO',6,'{\"id_usuario\":6,\"id_empleado\":null,\"nombre_usuario\":\"Dayana Santafe\",\"correo\":\"RH@barroblancofarms.com.co\",\"tipo_usuario\":\"PERSONAL_AUTORIZADO\",\"tipo_autenticacion\":\"LOCAL\",\"requiere_cambio_password\":1,\"correo_verificado\":0,\"estado\":\"INACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":null,\"created_at\":\"2026-06-22 17:07:10\",\"updated_at\":\"2026-06-22 21:14:44\",\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','{\"id_usuario\":6,\"id_empleado\":null,\"nombre_usuario\":\"Dayana Santafe\",\"correo\":\"RH@barroblancofarms.com.co\",\"tipo_usuario\":\"PERSONAL_AUTORIZADO\",\"tipo_autenticacion\":\"LOCAL\",\"requiere_cambio_password\":1,\"correo_verificado\":0,\"estado\":\"ELIMINADO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":null,\"created_at\":\"2026-06-22 17:07:10\",\"updated_at\":\"2026-06-22 21:38:30\",\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 21:38:30'),(79,8,'USUARIOS','CREAR','USUARIO',11,NULL,'{\"id_usuario\":11,\"id_empleado\":null,\"nombre_usuario\":\"test\",\"correo\":\"test@email.com\",\"tipo_usuario\":\"EMPLEADO\",\"tipo_autenticacion\":\"LOCAL\",\"requiere_cambio_password\":0,\"correo_verificado\":0,\"estado\":\"ACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":null,\"created_at\":\"2026-06-22 21:49:47\",\"updated_at\":null,\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 21:49:47'),(80,8,'USUARIOS','CAMBIAR_ESTADO','USUARIO',11,'{\"id_usuario\":11,\"id_empleado\":null,\"nombre_usuario\":\"test\",\"correo\":\"test@email.com\",\"tipo_usuario\":\"EMPLEADO\",\"tipo_autenticacion\":\"LOCAL\",\"requiere_cambio_password\":0,\"correo_verificado\":0,\"estado\":\"ACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":null,\"created_at\":\"2026-06-22 21:49:47\",\"updated_at\":null,\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','{\"id_usuario\":11,\"id_empleado\":null,\"nombre_usuario\":\"test\",\"correo\":\"test@email.com\",\"tipo_usuario\":\"EMPLEADO\",\"tipo_autenticacion\":\"LOCAL\",\"requiere_cambio_password\":0,\"correo_verificado\":0,\"estado\":\"ELIMINADO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":null,\"created_at\":\"2026-06-22 21:49:47\",\"updated_at\":\"2026-06-22 21:49:58\",\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 21:49:58'),(81,1,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',1,NULL,'{\"correo\":\"admin@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 21:57:09'),(82,1,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',1,NULL,'{\"correo\":\"admin@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 21:57:37'),(83,1,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',1,NULL,'{\"correo\":\"admin@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 21:58:15'),(84,1,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',1,NULL,'{\"correo\":\"admin@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 22:03:42'),(85,1,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',1,NULL,'{\"correo\":\"admin@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 22:03:57'),(86,1,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',1,NULL,'{\"correo\":\"admin@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 22:04:36'),(87,1,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',1,NULL,'{\"correo\":\"admin@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 22:05:04'),(88,1,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',1,NULL,'{\"correo\":\"admin@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 22:05:26'),(89,1,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',1,NULL,'{\"correo\":\"admin@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 22:05:53'),(90,1,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',1,NULL,'{\"correo\":\"admin@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 22:06:15'),(91,8,'USUARIOS','CREAR','USUARIO',12,NULL,'{\"id_usuario\":12,\"id_empleado\":null,\"nombre_usuario\":\"ANG\",\"correo\":\"ang@barroblancofarms.com.co\",\"tipo_usuario\":\"EMPLEADO\",\"tipo_autenticacion\":\"DOMINIO_EMPRESA\",\"requiere_cambio_password\":0,\"correo_verificado\":0,\"estado\":\"ACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":null,\"created_at\":\"2026-06-22 22:15:23\",\"updated_at\":null,\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 22:15:23'),(92,8,'USUARIOS','ASIGNAR_ROL','USUARIO',12,NULL,'{\"id_rol\":6}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 22:17:16'),(93,8,'AUTENTICACION','LOGOUT','USUARIO_SESION',36,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 22:17:24'),(94,12,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',12,NULL,'{\"correo\":\"ang@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 22:17:53'),(95,12,'AUTENTICACION','LOGOUT','USUARIO_SESION',44,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 22:18:45'),(96,1,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',1,NULL,'{\"correo\":\"admin@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 22:19:39'),(97,1,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',1,NULL,'{\"correo\":\"admin@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 22:44:01'),(98,1,'EMPLEADOS','CREAR','EMPLEADO',1,NULL,'{\"id_empleado\":1,\"id_tipo_documento\":1,\"tipo_documento\":\"QA Cedula\",\"numero_documento\":\"DOC-1782186241\",\"nombres\":\"QA Nombre\",\"apellidos\":\"QA Apellido\",\"nombre_completo\":\"QA Nombre QA Apellido\",\"correo\":\"qa.empleado.1782186241@barroblancofarms.com.co\",\"telefono\":\"3000000000\",\"id_area\":1,\"area\":\"QA Area Empleados\",\"id_cargo\":1,\"cargo\":\"QA Cargo Inicial\",\"id_tipo_contrato\":1,\"tipo_contrato\":\"QA Contrato\",\"fecha_ingreso\":\"2026-06-01\",\"fecha_retiro\":null,\"estado_empleado\":\"ACTIVO\",\"observaciones\":\"Empleado de validacion API\",\"created_at\":\"2026-06-22 22:44:02\",\"updated_at\":null}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 22:44:02'),(99,1,'EMPLEADOS','ACTUALIZAR','EMPLEADO',1,'{\"id_empleado\":1,\"id_tipo_documento\":1,\"tipo_documento\":\"QA Cedula\",\"numero_documento\":\"DOC-1782186241\",\"nombres\":\"QA Nombre\",\"apellidos\":\"QA Apellido\",\"nombre_completo\":\"QA Nombre QA Apellido\",\"correo\":\"qa.empleado.1782186241@barroblancofarms.com.co\",\"telefono\":\"3000000000\",\"id_area\":1,\"area\":\"QA Area Empleados\",\"id_cargo\":1,\"cargo\":\"QA Cargo Inicial\",\"id_tipo_contrato\":1,\"tipo_contrato\":\"QA Contrato\",\"fecha_ingreso\":\"2026-06-01\",\"fecha_retiro\":null,\"estado_empleado\":\"ACTIVO\",\"observaciones\":\"Empleado de validacion API\",\"created_at\":\"2026-06-22 22:44:02\",\"updated_at\":null}','{\"id_empleado\":1,\"id_tipo_documento\":1,\"tipo_documento\":\"QA Cedula\",\"numero_documento\":\"DOC-1782186241\",\"nombres\":\"QA Nombre Editado\",\"apellidos\":\"QA Apellido Editado\",\"nombre_completo\":\"QA Nombre Editado QA Apellido Editado\",\"correo\":\"qa.empleado.editado.1782186241@barroblancofarms.com.co\",\"telefono\":\"3111111111\",\"id_area\":1,\"area\":\"QA Area Empleados\",\"id_cargo\":2,\"cargo\":\"QA Cargo Editado\",\"id_tipo_contrato\":1,\"tipo_contrato\":\"QA Contrato\",\"fecha_ingreso\":\"2026-06-01\",\"fecha_retiro\":null,\"estado_empleado\":\"ACTIVO\",\"observaciones\":\"Empleado editado API\",\"created_at\":\"2026-06-22 22:44:02\",\"updated_at\":\"2026-06-22 22:44:03\"}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 22:44:03'),(100,1,'EMPLEADOS','CREAR','EMPLEADO',2,NULL,'{\"id_empleado\":2,\"id_tipo_documento\":1,\"tipo_documento\":\"QA Cedula\",\"numero_documento\":\"DUP-1782186241\",\"nombres\":\"QA Nombre\",\"apellidos\":\"QA Apellido\",\"nombre_completo\":\"QA Nombre QA Apellido\",\"correo\":\"dup1.1782186241@barroblancofarms.com.co\",\"telefono\":\"3000000000\",\"id_area\":1,\"area\":\"QA Area Empleados\",\"id_cargo\":1,\"cargo\":\"QA Cargo Inicial\",\"id_tipo_contrato\":1,\"tipo_contrato\":\"QA Contrato\",\"fecha_ingreso\":\"2026-06-01\",\"fecha_retiro\":null,\"estado_empleado\":\"ACTIVO\",\"observaciones\":\"Empleado de validacion API\",\"created_at\":\"2026-06-22 22:44:04\",\"updated_at\":null}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 22:44:04'),(101,1,'EMPLEADOS','ELIMINAR','EMPLEADO',2,'{\"id_empleado\":2,\"id_tipo_documento\":1,\"tipo_documento\":\"QA Cedula\",\"numero_documento\":\"DUP-1782186241\",\"nombres\":\"QA Nombre\",\"apellidos\":\"QA Apellido\",\"nombre_completo\":\"QA Nombre QA Apellido\",\"correo\":\"dup1.1782186241@barroblancofarms.com.co\",\"telefono\":\"3000000000\",\"id_area\":1,\"area\":\"QA Area Empleados\",\"id_cargo\":1,\"cargo\":\"QA Cargo Inicial\",\"id_tipo_contrato\":1,\"tipo_contrato\":\"QA Contrato\",\"fecha_ingreso\":\"2026-06-01\",\"fecha_retiro\":null,\"estado_empleado\":\"ACTIVO\",\"observaciones\":\"Empleado de validacion API\",\"created_at\":\"2026-06-22 22:44:04\",\"updated_at\":null}','{\"id_empleado\":2,\"eliminado\":true}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 22:44:05'),(102,1,'EMPLEADOS','CAMBIAR_ESTADO','EMPLEADO',1,'{\"id_empleado\":1,\"id_tipo_documento\":1,\"tipo_documento\":\"QA Cedula\",\"numero_documento\":\"DOC-1782186241\",\"nombres\":\"QA Nombre Editado\",\"apellidos\":\"QA Apellido Editado\",\"nombre_completo\":\"QA Nombre Editado QA Apellido Editado\",\"correo\":\"qa.empleado.editado.1782186241@barroblancofarms.com.co\",\"telefono\":\"3111111111\",\"id_area\":1,\"area\":\"QA Area Empleados\",\"id_cargo\":2,\"cargo\":\"QA Cargo Editado\",\"id_tipo_contrato\":1,\"tipo_contrato\":\"QA Contrato\",\"fecha_ingreso\":\"2026-06-01\",\"fecha_retiro\":null,\"estado_empleado\":\"ACTIVO\",\"observaciones\":\"Empleado editado API\",\"created_at\":\"2026-06-22 22:44:02\",\"updated_at\":\"2026-06-22 22:44:03\"}','{\"id_empleado\":1,\"id_tipo_documento\":1,\"tipo_documento\":\"QA Cedula\",\"numero_documento\":\"DOC-1782186241\",\"nombres\":\"QA Nombre Editado\",\"apellidos\":\"QA Apellido Editado\",\"nombre_completo\":\"QA Nombre Editado QA Apellido Editado\",\"correo\":\"qa.empleado.editado.1782186241@barroblancofarms.com.co\",\"telefono\":\"3111111111\",\"id_area\":1,\"area\":\"QA Area Empleados\",\"id_cargo\":2,\"cargo\":\"QA Cargo Editado\",\"id_tipo_contrato\":1,\"tipo_contrato\":\"QA Contrato\",\"fecha_ingreso\":\"2026-06-01\",\"fecha_retiro\":null,\"estado_empleado\":\"SUSPENDIDO\",\"observaciones\":\"Empleado editado API\",\"created_at\":\"2026-06-22 22:44:02\",\"updated_at\":\"2026-06-22 22:44:06\"}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 22:44:06'),(103,1,'EMPLEADOS','CAMBIAR_ESTADO','EMPLEADO',1,'{\"id_empleado\":1,\"id_tipo_documento\":1,\"tipo_documento\":\"QA Cedula\",\"numero_documento\":\"DOC-1782186241\",\"nombres\":\"QA Nombre Editado\",\"apellidos\":\"QA Apellido Editado\",\"nombre_completo\":\"QA Nombre Editado QA Apellido Editado\",\"correo\":\"qa.empleado.editado.1782186241@barroblancofarms.com.co\",\"telefono\":\"3111111111\",\"id_area\":1,\"area\":\"QA Area Empleados\",\"id_cargo\":2,\"cargo\":\"QA Cargo Editado\",\"id_tipo_contrato\":1,\"tipo_contrato\":\"QA Contrato\",\"fecha_ingreso\":\"2026-06-01\",\"fecha_retiro\":null,\"estado_empleado\":\"SUSPENDIDO\",\"observaciones\":\"Empleado editado API\",\"created_at\":\"2026-06-22 22:44:02\",\"updated_at\":\"2026-06-22 22:44:06\"}','{\"id_empleado\":1,\"id_tipo_documento\":1,\"tipo_documento\":\"QA Cedula\",\"numero_documento\":\"DOC-1782186241\",\"nombres\":\"QA Nombre Editado\",\"apellidos\":\"QA Apellido Editado\",\"nombre_completo\":\"QA Nombre Editado QA Apellido Editado\",\"correo\":\"qa.empleado.editado.1782186241@barroblancofarms.com.co\",\"telefono\":\"3111111111\",\"id_area\":1,\"area\":\"QA Area Empleados\",\"id_cargo\":2,\"cargo\":\"QA Cargo Editado\",\"id_tipo_contrato\":1,\"tipo_contrato\":\"QA Contrato\",\"fecha_ingreso\":\"2026-06-01\",\"fecha_retiro\":\"2026-06-22\",\"estado_empleado\":\"RETIRADO\",\"observaciones\":\"Empleado editado API\",\"created_at\":\"2026-06-22 22:44:02\",\"updated_at\":\"2026-06-22 22:44:06\"}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 22:44:06'),(104,1,'EMPLEADOS','CAMBIAR_ESTADO','EMPLEADO',1,'{\"id_empleado\":1,\"id_tipo_documento\":1,\"tipo_documento\":\"QA Cedula\",\"numero_documento\":\"DOC-1782186241\",\"nombres\":\"QA Nombre Editado\",\"apellidos\":\"QA Apellido Editado\",\"nombre_completo\":\"QA Nombre Editado QA Apellido Editado\",\"correo\":\"qa.empleado.editado.1782186241@barroblancofarms.com.co\",\"telefono\":\"3111111111\",\"id_area\":1,\"area\":\"QA Area Empleados\",\"id_cargo\":2,\"cargo\":\"QA Cargo Editado\",\"id_tipo_contrato\":1,\"tipo_contrato\":\"QA Contrato\",\"fecha_ingreso\":\"2026-06-01\",\"fecha_retiro\":\"2026-06-22\",\"estado_empleado\":\"RETIRADO\",\"observaciones\":\"Empleado editado API\",\"created_at\":\"2026-06-22 22:44:02\",\"updated_at\":\"2026-06-22 22:44:06\"}','{\"id_empleado\":1,\"id_tipo_documento\":1,\"tipo_documento\":\"QA Cedula\",\"numero_documento\":\"DOC-1782186241\",\"nombres\":\"QA Nombre Editado\",\"apellidos\":\"QA Apellido Editado\",\"nombre_completo\":\"QA Nombre Editado QA Apellido Editado\",\"correo\":\"qa.empleado.editado.1782186241@barroblancofarms.com.co\",\"telefono\":\"3111111111\",\"id_area\":1,\"area\":\"QA Area Empleados\",\"id_cargo\":2,\"cargo\":\"QA Cargo Editado\",\"id_tipo_contrato\":1,\"tipo_contrato\":\"QA Contrato\",\"fecha_ingreso\":\"2026-06-01\",\"fecha_retiro\":null,\"estado_empleado\":\"ACTIVO\",\"observaciones\":\"Empleado editado API\",\"created_at\":\"2026-06-22 22:44:02\",\"updated_at\":\"2026-06-22 22:44:07\"}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 22:44:07'),(105,1,'EMPLEADOS','ELIMINAR','EMPLEADO',1,'{\"id_empleado\":1,\"id_tipo_documento\":1,\"tipo_documento\":\"QA Cedula\",\"numero_documento\":\"DOC-1782186241\",\"nombres\":\"QA Nombre Editado\",\"apellidos\":\"QA Apellido Editado\",\"nombre_completo\":\"QA Nombre Editado QA Apellido Editado\",\"correo\":\"qa.empleado.editado.1782186241@barroblancofarms.com.co\",\"telefono\":\"3111111111\",\"id_area\":1,\"area\":\"QA Area Empleados\",\"id_cargo\":2,\"cargo\":\"QA Cargo Editado\",\"id_tipo_contrato\":1,\"tipo_contrato\":\"QA Contrato\",\"fecha_ingreso\":\"2026-06-01\",\"fecha_retiro\":null,\"estado_empleado\":\"ACTIVO\",\"observaciones\":\"Empleado editado API\",\"created_at\":\"2026-06-22 22:44:02\",\"updated_at\":\"2026-06-22 22:44:07\"}','{\"id_empleado\":1,\"eliminado\":true}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 22:44:07'),(106,1,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',1,NULL,'{\"correo\":\"admin@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 22:51:23'),(107,1,'EMPLEADOS','CREAR','EMPLEADO',3,NULL,'{\"id_empleado\":3,\"id_tipo_documento\":1,\"tipo_documento\":\"QA Cedula\",\"numero_documento\":\"FRONT-1782186686\",\"nombres\":\"Front Nombre\",\"apellidos\":\"Front Apellido\",\"nombre_completo\":\"Front Nombre Front Apellido\",\"correo\":\"front.empleado.1782186686@barroblancofarms.com.co\",\"telefono\":\"3220000000\",\"id_area\":1,\"area\":\"QA Area Empleados\",\"id_cargo\":1,\"cargo\":\"QA Cargo Inicial\",\"id_tipo_contrato\":1,\"tipo_contrato\":\"QA Contrato\",\"fecha_ingreso\":\"2026-06-01\",\"fecha_retiro\":null,\"estado_empleado\":\"ACTIVO\",\"observaciones\":\"Validacion frontend empleados\",\"created_at\":\"2026-06-22 22:51:27\",\"updated_at\":null}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 22:51:27'),(108,1,'EMPLEADOS','ACTUALIZAR','EMPLEADO',3,'{\"id_empleado\":3,\"id_tipo_documento\":1,\"tipo_documento\":\"QA Cedula\",\"numero_documento\":\"FRONT-1782186686\",\"nombres\":\"Front Nombre\",\"apellidos\":\"Front Apellido\",\"nombre_completo\":\"Front Nombre Front Apellido\",\"correo\":\"front.empleado.1782186686@barroblancofarms.com.co\",\"telefono\":\"3220000000\",\"id_area\":1,\"area\":\"QA Area Empleados\",\"id_cargo\":1,\"cargo\":\"QA Cargo Inicial\",\"id_tipo_contrato\":1,\"tipo_contrato\":\"QA Contrato\",\"fecha_ingreso\":\"2026-06-01\",\"fecha_retiro\":null,\"estado_empleado\":\"ACTIVO\",\"observaciones\":\"Validacion frontend empleados\",\"created_at\":\"2026-06-22 22:51:27\",\"updated_at\":null}','{\"id_empleado\":3,\"id_tipo_documento\":1,\"tipo_documento\":\"QA Cedula\",\"numero_documento\":\"FRONT-1782186686\",\"nombres\":\"Front Nombre Editado\",\"apellidos\":\"Front Apellido Editado\",\"nombre_completo\":\"Front Nombre Editado Front Apellido Editado\",\"correo\":\"front.editado.1782186686@barroblancofarms.com.co\",\"telefono\":\"3220000000\",\"id_area\":1,\"area\":\"QA Area Empleados\",\"id_cargo\":2,\"cargo\":\"QA Cargo Editado\",\"id_tipo_contrato\":1,\"tipo_contrato\":\"QA Contrato\",\"fecha_ingreso\":\"2026-06-01\",\"fecha_retiro\":null,\"estado_empleado\":\"ACTIVO\",\"observaciones\":\"Validacion frontend empleados\",\"created_at\":\"2026-06-22 22:51:27\",\"updated_at\":\"2026-06-22 22:51:28\"}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 22:51:28'),(109,1,'EMPLEADOS','CAMBIAR_ESTADO','EMPLEADO',3,'{\"id_empleado\":3,\"id_tipo_documento\":1,\"tipo_documento\":\"QA Cedula\",\"numero_documento\":\"FRONT-1782186686\",\"nombres\":\"Front Nombre Editado\",\"apellidos\":\"Front Apellido Editado\",\"nombre_completo\":\"Front Nombre Editado Front Apellido Editado\",\"correo\":\"front.editado.1782186686@barroblancofarms.com.co\",\"telefono\":\"3220000000\",\"id_area\":1,\"area\":\"QA Area Empleados\",\"id_cargo\":2,\"cargo\":\"QA Cargo Editado\",\"id_tipo_contrato\":1,\"tipo_contrato\":\"QA Contrato\",\"fecha_ingreso\":\"2026-06-01\",\"fecha_retiro\":null,\"estado_empleado\":\"ACTIVO\",\"observaciones\":\"Validacion frontend empleados\",\"created_at\":\"2026-06-22 22:51:27\",\"updated_at\":\"2026-06-22 22:51:28\"}','{\"id_empleado\":3,\"id_tipo_documento\":1,\"tipo_documento\":\"QA Cedula\",\"numero_documento\":\"FRONT-1782186686\",\"nombres\":\"Front Nombre Editado\",\"apellidos\":\"Front Apellido Editado\",\"nombre_completo\":\"Front Nombre Editado Front Apellido Editado\",\"correo\":\"front.editado.1782186686@barroblancofarms.com.co\",\"telefono\":\"3220000000\",\"id_area\":1,\"area\":\"QA Area Empleados\",\"id_cargo\":2,\"cargo\":\"QA Cargo Editado\",\"id_tipo_contrato\":1,\"tipo_contrato\":\"QA Contrato\",\"fecha_ingreso\":\"2026-06-01\",\"fecha_retiro\":null,\"estado_empleado\":\"SUSPENDIDO\",\"observaciones\":\"Validacion frontend empleados\",\"created_at\":\"2026-06-22 22:51:27\",\"updated_at\":\"2026-06-22 22:51:29\"}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 22:51:29'),(110,1,'EMPLEADOS','CAMBIAR_ESTADO','EMPLEADO',3,'{\"id_empleado\":3,\"id_tipo_documento\":1,\"tipo_documento\":\"QA Cedula\",\"numero_documento\":\"FRONT-1782186686\",\"nombres\":\"Front Nombre Editado\",\"apellidos\":\"Front Apellido Editado\",\"nombre_completo\":\"Front Nombre Editado Front Apellido Editado\",\"correo\":\"front.editado.1782186686@barroblancofarms.com.co\",\"telefono\":\"3220000000\",\"id_area\":1,\"area\":\"QA Area Empleados\",\"id_cargo\":2,\"cargo\":\"QA Cargo Editado\",\"id_tipo_contrato\":1,\"tipo_contrato\":\"QA Contrato\",\"fecha_ingreso\":\"2026-06-01\",\"fecha_retiro\":null,\"estado_empleado\":\"SUSPENDIDO\",\"observaciones\":\"Validacion frontend empleados\",\"created_at\":\"2026-06-22 22:51:27\",\"updated_at\":\"2026-06-22 22:51:29\"}','{\"id_empleado\":3,\"id_tipo_documento\":1,\"tipo_documento\":\"QA Cedula\",\"numero_documento\":\"FRONT-1782186686\",\"nombres\":\"Front Nombre Editado\",\"apellidos\":\"Front Apellido Editado\",\"nombre_completo\":\"Front Nombre Editado Front Apellido Editado\",\"correo\":\"front.editado.1782186686@barroblancofarms.com.co\",\"telefono\":\"3220000000\",\"id_area\":1,\"area\":\"QA Area Empleados\",\"id_cargo\":2,\"cargo\":\"QA Cargo Editado\",\"id_tipo_contrato\":1,\"tipo_contrato\":\"QA Contrato\",\"fecha_ingreso\":\"2026-06-01\",\"fecha_retiro\":\"2026-06-22\",\"estado_empleado\":\"RETIRADO\",\"observaciones\":\"Validacion frontend empleados\",\"created_at\":\"2026-06-22 22:51:27\",\"updated_at\":\"2026-06-22 22:51:29\"}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 22:51:29'),(111,1,'EMPLEADOS','CAMBIAR_ESTADO','EMPLEADO',3,'{\"id_empleado\":3,\"id_tipo_documento\":1,\"tipo_documento\":\"QA Cedula\",\"numero_documento\":\"FRONT-1782186686\",\"nombres\":\"Front Nombre Editado\",\"apellidos\":\"Front Apellido Editado\",\"nombre_completo\":\"Front Nombre Editado Front Apellido Editado\",\"correo\":\"front.editado.1782186686@barroblancofarms.com.co\",\"telefono\":\"3220000000\",\"id_area\":1,\"area\":\"QA Area Empleados\",\"id_cargo\":2,\"cargo\":\"QA Cargo Editado\",\"id_tipo_contrato\":1,\"tipo_contrato\":\"QA Contrato\",\"fecha_ingreso\":\"2026-06-01\",\"fecha_retiro\":\"2026-06-22\",\"estado_empleado\":\"RETIRADO\",\"observaciones\":\"Validacion frontend empleados\",\"created_at\":\"2026-06-22 22:51:27\",\"updated_at\":\"2026-06-22 22:51:29\"}','{\"id_empleado\":3,\"id_tipo_documento\":1,\"tipo_documento\":\"QA Cedula\",\"numero_documento\":\"FRONT-1782186686\",\"nombres\":\"Front Nombre Editado\",\"apellidos\":\"Front Apellido Editado\",\"nombre_completo\":\"Front Nombre Editado Front Apellido Editado\",\"correo\":\"front.editado.1782186686@barroblancofarms.com.co\",\"telefono\":\"3220000000\",\"id_area\":1,\"area\":\"QA Area Empleados\",\"id_cargo\":2,\"cargo\":\"QA Cargo Editado\",\"id_tipo_contrato\":1,\"tipo_contrato\":\"QA Contrato\",\"fecha_ingreso\":\"2026-06-01\",\"fecha_retiro\":null,\"estado_empleado\":\"ACTIVO\",\"observaciones\":\"Validacion frontend empleados\",\"created_at\":\"2026-06-22 22:51:27\",\"updated_at\":\"2026-06-22 22:51:30\"}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 22:51:30'),(112,1,'EMPLEADOS','ELIMINAR','EMPLEADO',3,'{\"id_empleado\":3,\"id_tipo_documento\":1,\"tipo_documento\":\"QA Cedula\",\"numero_documento\":\"FRONT-1782186686\",\"nombres\":\"Front Nombre Editado\",\"apellidos\":\"Front Apellido Editado\",\"nombre_completo\":\"Front Nombre Editado Front Apellido Editado\",\"correo\":\"front.editado.1782186686@barroblancofarms.com.co\",\"telefono\":\"3220000000\",\"id_area\":1,\"area\":\"QA Area Empleados\",\"id_cargo\":2,\"cargo\":\"QA Cargo Editado\",\"id_tipo_contrato\":1,\"tipo_contrato\":\"QA Contrato\",\"fecha_ingreso\":\"2026-06-01\",\"fecha_retiro\":null,\"estado_empleado\":\"ACTIVO\",\"observaciones\":\"Validacion frontend empleados\",\"created_at\":\"2026-06-22 22:51:27\",\"updated_at\":\"2026-06-22 22:51:30\"}','{\"id_empleado\":3,\"eliminado\":true}','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 22:51:30'),(113,1,'AUTENTICACION','LOGOUT','USUARIO_SESION',45,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 22:53:15'),(114,8,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',8,NULL,'{\"correo\":\"Ad@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 22:53:30'),(115,8,'EMPLEADOS','CREAR','EMPLEADO',4,NULL,'{\"id_empleado\":4,\"id_tipo_documento\":null,\"tipo_documento\":null,\"numero_documento\":\"1072708535\",\"nombres\":\"Ricardo\",\"apellidos\":\"CArdenas\",\"nombre_completo\":\"Ricardo CArdenas\",\"correo\":\"r@email.com\",\"telefono\":\"3194400951\",\"id_area\":null,\"area\":null,\"id_cargo\":null,\"cargo\":null,\"id_tipo_contrato\":null,\"tipo_contrato\":null,\"fecha_ingreso\":\"2026-06-22\",\"fecha_retiro\":null,\"estado_empleado\":\"ACTIVO\",\"observaciones\":null,\"created_at\":\"2026-06-22 22:54:19\",\"updated_at\":null}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 22:54:19'),(116,8,'EMPLEADOS','CAMBIAR_ESTADO','EMPLEADO',4,'{\"id_empleado\":4,\"id_tipo_documento\":null,\"tipo_documento\":null,\"numero_documento\":\"1072708535\",\"nombres\":\"Ricardo\",\"apellidos\":\"CArdenas\",\"nombre_completo\":\"Ricardo CArdenas\",\"correo\":\"r@email.com\",\"telefono\":\"3194400951\",\"id_area\":null,\"area\":null,\"id_cargo\":null,\"cargo\":null,\"id_tipo_contrato\":null,\"tipo_contrato\":null,\"fecha_ingreso\":\"2026-06-22\",\"fecha_retiro\":null,\"estado_empleado\":\"ACTIVO\",\"observaciones\":null,\"created_at\":\"2026-06-22 22:54:19\",\"updated_at\":null}','{\"id_empleado\":4,\"id_tipo_documento\":null,\"tipo_documento\":null,\"numero_documento\":\"1072708535\",\"nombres\":\"Ricardo\",\"apellidos\":\"CArdenas\",\"nombre_completo\":\"Ricardo CArdenas\",\"correo\":\"r@email.com\",\"telefono\":\"3194400951\",\"id_area\":null,\"area\":null,\"id_cargo\":null,\"cargo\":null,\"id_tipo_contrato\":null,\"tipo_contrato\":null,\"fecha_ingreso\":\"2026-06-22\",\"fecha_retiro\":null,\"estado_empleado\":\"INCAPACITADO\",\"observaciones\":null,\"created_at\":\"2026-06-22 22:54:19\",\"updated_at\":\"2026-06-22 22:54:40\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 22:54:41'),(117,8,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',8,NULL,'{\"correo\":\"Ad@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 09:00:47'),(118,8,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',8,NULL,'{\"correo\":\"Ad@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 09:01:05'),(119,8,'EMPLEADOS','ACTUALIZAR','EMPLEADO',4,'{\"id_empleado\":4,\"id_tipo_documento\":null,\"tipo_documento\":null,\"numero_documento\":\"1072708535\",\"nombres\":\"Ricardo\",\"apellidos\":\"CArdenas\",\"nombre_completo\":\"Ricardo CArdenas\",\"correo\":\"r@email.com\",\"telefono\":\"3194400951\",\"id_area\":null,\"area\":null,\"id_cargo\":null,\"cargo\":null,\"id_tipo_contrato\":null,\"tipo_contrato\":null,\"fecha_ingreso\":\"2026-06-22\",\"fecha_retiro\":null,\"estado_empleado\":\"INCAPACITADO\",\"observaciones\":null,\"created_at\":\"2026-06-22 22:54:19\",\"updated_at\":\"2026-06-22 22:54:40\"}','{\"id_empleado\":4,\"id_tipo_documento\":2,\"tipo_documento\":\"Cédula de ciudadanía\",\"numero_documento\":\"1072708535\",\"nombres\":\"Ricardo\",\"apellidos\":\"CArdenas\",\"nombre_completo\":\"Ricardo CArdenas\",\"correo\":\"r@email.com\",\"telefono\":\"3194400951\",\"id_area\":null,\"area\":null,\"id_cargo\":null,\"cargo\":null,\"id_tipo_contrato\":null,\"tipo_contrato\":null,\"fecha_ingreso\":\"2026-06-22\",\"fecha_retiro\":null,\"estado_empleado\":\"INCAPACITADO\",\"observaciones\":null,\"created_at\":\"2026-06-22 22:54:19\",\"updated_at\":\"2026-06-23 09:54:58\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 09:54:58'),(120,8,'USUARIOS','CAMBIAR_ESTADO','USUARIO',12,'{\"id_usuario\":12,\"id_empleado\":null,\"nombre_usuario\":\"ANG\",\"correo\":\"ang@barroblancofarms.com.co\",\"tipo_usuario\":\"EMPLEADO\",\"tipo_autenticacion\":\"DOMINIO_EMPRESA\",\"requiere_cambio_password\":0,\"correo_verificado\":0,\"estado\":\"ACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":\"2026-06-22 22:17:53\",\"created_at\":\"2026-06-22 22:15:23\",\"updated_at\":\"2026-06-22 22:17:53\",\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','{\"id_usuario\":12,\"id_empleado\":null,\"nombre_usuario\":\"ANG\",\"correo\":\"ang@barroblancofarms.com.co\",\"tipo_usuario\":\"EMPLEADO\",\"tipo_autenticacion\":\"DOMINIO_EMPRESA\",\"requiere_cambio_password\":0,\"correo_verificado\":0,\"estado\":\"ELIMINADO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":\"2026-06-22 22:17:53\",\"created_at\":\"2026-06-22 22:15:23\",\"updated_at\":\"2026-06-23 09:56:05\",\"nombres\":null,\"apellidos\":null,\"nombre_completo\":null}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 09:56:05'),(121,8,'EMPLEADOS','ELIMINAR','EMPLEADO',4,'{\"id_empleado\":4,\"id_tipo_documento\":2,\"tipo_documento\":\"Cédula de ciudadanía\",\"numero_documento\":\"1072708535\",\"nombres\":\"Ricardo\",\"apellidos\":\"CArdenas\",\"nombre_completo\":\"Ricardo CArdenas\",\"correo\":\"r@email.com\",\"telefono\":\"3194400951\",\"id_area\":null,\"area\":null,\"id_cargo\":null,\"cargo\":null,\"id_tipo_contrato\":null,\"tipo_contrato\":null,\"fecha_ingreso\":\"2026-06-22\",\"fecha_retiro\":null,\"estado_empleado\":\"INCAPACITADO\",\"observaciones\":null,\"created_at\":\"2026-06-22 22:54:19\",\"updated_at\":\"2026-06-23 09:54:58\"}','{\"id_empleado\":4,\"eliminado\":true}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 10:12:30'),(122,8,'EMPLEADOS','CREAR','EMPLEADO',5,NULL,'{\"id_empleado\":5,\"id_tipo_documento\":2,\"tipo_documento\":\"Cédula de ciudadanía\",\"numero_documento\":\"123456789\",\"nombres\":\"Juan\",\"apellidos\":\"Barco\",\"nombre_completo\":\"Juan Barco\",\"correo\":\"JC@email.com\",\"telefono\":\"3194400951\",\"id_area\":5,\"area\":\"Cultivo\",\"id_cargo\":8,\"cargo\":\"Operario\",\"id_tipo_contrato\":4,\"tipo_contrato\":\"Obra o labor\",\"fecha_ingreso\":\"2026-06-01\",\"fecha_retiro\":null,\"estado_empleado\":\"ACTIVO\",\"observaciones\":\"Empleado test\",\"created_at\":\"2026-06-23 10:13:29\",\"updated_at\":null}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 10:13:29'),(123,8,'EMPLEADOS','CREAR','EMPLEADO',6,NULL,'{\"id_empleado\":6,\"id_tipo_documento\":2,\"tipo_documento\":\"Cédula de ciudadanía\",\"numero_documento\":\"2606231\",\"nombres\":\"Alfredo\",\"apellidos\":\"Gomez\",\"nombre_completo\":\"Alfredo Gomez\",\"correo\":\"ag@email.com\",\"telefono\":\"3194578951\",\"foto_url\":null,\"id_area\":8,\"area\":\"Calidad\",\"id_cargo\":9,\"cargo\":\"Operario de Cultivo\",\"id_tipo_contrato\":7,\"tipo_contrato\":\"Temporal\",\"fecha_ingreso\":\"2026-05-31\",\"fecha_retiro\":null,\"estado_empleado\":\"ACTIVO\",\"observaciones\":null,\"created_at\":\"2026-06-23 10:53:23\",\"updated_at\":null}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 10:53:23'),(124,8,'USUARIOS','CREAR','USUARIO',13,NULL,'{\"id_usuario\":13,\"id_empleado\":6,\"nombre_usuario\":\"aGomez\",\"correo\":\"ag@email.com\",\"tipo_usuario\":\"EMPLEADO\",\"tipo_autenticacion\":\"LOCAL\",\"requiere_cambio_password\":0,\"correo_verificado\":0,\"estado\":\"ACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":null,\"created_at\":\"2026-06-23 10:55:38\",\"updated_at\":null,\"nombres\":\"Alfredo\",\"apellidos\":\"Gomez\",\"nombre_completo\":\"Alfredo Gomez\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 10:55:38'),(125,8,'AUTENTICACION','LOGOUT','USUARIO_SESION',55,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 11:08:01'),(126,8,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',8,NULL,'{\"correo\":\"Ad@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 11:08:16'),(127,8,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',8,NULL,'{\"correo\":\"Ad@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 11:49:26'),(128,8,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',8,NULL,'{\"correo\":\"Ad@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 11:49:34'),(129,8,'USUARIOS','ASIGNAR_ROL','USUARIO',13,NULL,'{\"id_rol\":7}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 11:55:08'),(130,13,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',13,NULL,'{\"correo\":\"ag@email.com\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-23 11:55:37'),(131,13,'DOTACIONES','DOTACIONES_MI_TALLA_GUARDAR','DOTACION_TALLA',1,NULL,'{\"id_empleado_dotacion_talla\":1,\"id_empleado\":6,\"id_tipo_dotacion\":3,\"tipo_dotacion\":\"Calzado\",\"id_talla_dotacion\":32,\"talla\":\"34\",\"observaciones\":null}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-23 11:56:35'),(132,13,'DOTACIONES','DOTACIONES_MI_TALLA_GUARDAR','DOTACION_TALLA',2,NULL,'{\"id_empleado_dotacion_talla\":2,\"id_empleado\":6,\"id_tipo_dotacion\":1,\"tipo_dotacion\":\"Camisa\",\"id_talla_dotacion\":1,\"talla\":\"XS\",\"observaciones\":null}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-23 11:56:40'),(133,13,'DOTACIONES','DOTACIONES_MI_TALLA_GUARDAR','DOTACION_TALLA',3,NULL,'{\"id_empleado_dotacion_talla\":3,\"id_empleado\":6,\"id_tipo_dotacion\":7,\"tipo_dotacion\":\"Chaqueta\",\"id_talla_dotacion\":6,\"talla\":\"S\",\"observaciones\":null}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-23 11:56:43'),(134,13,'DOTACIONES','DOTACIONES_MI_TALLA_GUARDAR','DOTACION_TALLA',4,NULL,'{\"id_empleado_dotacion_talla\":4,\"id_empleado\":6,\"id_tipo_dotacion\":6,\"tipo_dotacion\":\"Delantal\",\"id_talla_dotacion\":15,\"talla\":\"L\",\"observaciones\":null}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-23 11:56:46'),(135,13,'DOTACIONES','DOTACIONES_MI_TALLA_GUARDAR','DOTACION_TALLA',5,NULL,'{\"id_empleado_dotacion_talla\":5,\"id_empleado\":6,\"id_tipo_dotacion\":5,\"tipo_dotacion\":\"Gorra\",\"id_talla_dotacion\":53,\"talla\":\"Única\",\"observaciones\":null}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-23 11:56:49'),(136,13,'DOTACIONES','DOTACIONES_MI_TALLA_GUARDAR','DOTACION_TALLA',6,NULL,'{\"id_empleado_dotacion_talla\":6,\"id_empleado\":6,\"id_tipo_dotacion\":4,\"tipo_dotacion\":\"Guantes\",\"id_talla_dotacion\":50,\"talla\":\"M\",\"observaciones\":null}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-23 11:56:53'),(137,13,'DOTACIONES','DOTACIONES_MI_TALLA_GUARDAR','DOTACION_TALLA',7,NULL,'{\"id_empleado_dotacion_talla\":7,\"id_empleado\":6,\"id_tipo_dotacion\":2,\"tipo_dotacion\":\"Pantalón\",\"id_talla_dotacion\":16,\"talla\":\"L\",\"observaciones\":null}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-23 11:56:56'),(138,8,'DOTACIONES','DOTACIONES_ENTREGA_CREAR','DOTACION_ENTREGA',1,NULL,'{\"request\":{\"id_empleado\":6,\"fecha_entrega\":\"2026-06-23\",\"observaciones\":\"Se entrega dotación\",\"detalles\":[{\"id_tipo_dotacion\":3,\"id_talla_dotacion\":36,\"cantidad\":1,\"observaciones\":null},{\"id_tipo_dotacion\":4,\"id_talla_dotacion\":54,\"cantidad\":2,\"observaciones\":null}]},\"result\":{\"id_dotacion_entrega\":1}}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 11:58:00'),(139,8,'DOTACIONES','DOTACIONES_ENTREGA_CREAR','DOTACION_ENTREGA',2,NULL,'{\"request\":{\"id_empleado\":6,\"fecha_entrega\":\"2026-06-23\",\"observaciones\":null,\"detalles\":[{\"id_tipo_dotacion\":4,\"id_talla_dotacion\":50,\"cantidad\":3,\"observaciones\":null}]},\"result\":{\"id_dotacion_entrega\":2}}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 12:00:07'),(140,8,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',8,NULL,'{\"correo\":\"Ad@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 18:12:57'),(141,8,'DOTACIONES','DOTACIONES_ENTREGA_CREAR','DOTACION_ENTREGA',3,NULL,'{\"request\":{\"id_empleado\":6,\"fecha_entrega\":\"2026-06-23\",\"observaciones\":null,\"detalles\":[{\"id_tipo_dotacion\":6,\"id_talla_dotacion\":15,\"cantidad\":2,\"observaciones\":\"me falto el blanco\"}]},\"result\":{\"id_dotacion_entrega\":3}}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 18:15:06'),(142,8,'AUTENTICACION','LOGOUT','USUARIO_SESION',61,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 19:51:10'),(143,8,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',8,NULL,'{\"correo\":\"Ad@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-23 20:00:51'),(144,8,'AUTENTICACION','LOGOUT','USUARIO_SESION',62,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-23 20:17:33'),(145,8,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',8,NULL,'{\"correo\":\"Ad@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-23 20:17:48'),(146,NULL,'AUTENTICACION','LOGIN_FALLIDO','USUARIO',NULL,NULL,'{\"usuario\":\"ag@email.comag@email.com\",\"motivo\":\"NO_EXISTE\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 20:19:57'),(147,13,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',13,NULL,'{\"correo\":\"ag@email.com\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 20:20:06'),(148,13,'AUTENTICACION','LOGOUT','USUARIO_SESION',64,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 20:20:56'),(149,13,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',13,NULL,'{\"correo\":\"ag@email.com\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 20:21:04'),(150,13,'AUTENTICACION','LOGOUT','USUARIO_SESION',65,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 20:22:55'),(151,13,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',13,NULL,'{\"correo\":\"ag@email.com\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 20:23:24'),(152,8,'AUTENTICACION','LOGOUT','USUARIO_SESION',63,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-23 20:32:38'),(153,8,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',8,NULL,'{\"correo\":\"Ad@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-23 20:32:51'),(154,13,'AUTENTICACION','LOGOUT','USUARIO_SESION',66,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 20:32:56'),(155,13,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',13,NULL,'{\"correo\":\"ag@email.com\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 20:33:29'),(156,13,'DOTACIONES','DOTACIONES_ENTREGA_CONFIRMAR_RECIBIDO','DOTACION_ENTREGA',1,NULL,'{\"id_usuario\":13,\"id_dotacion_entrega\":1,\"observacion_confirmacion\":\"Recibido en buen estado\",\"firma_url\":null}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 20:34:21'),(157,8,'EMPLEADOS','ELIMINAR','EMPLEADO',5,'{\"id_empleado\":5,\"id_tipo_documento\":2,\"tipo_documento\":\"Cédula de ciudadanía\",\"numero_documento\":\"123456789\",\"nombres\":\"Juan\",\"apellidos\":\"Barco\",\"nombre_completo\":\"Juan Barco\",\"correo\":\"JC@email.com\",\"telefono\":\"3194400951\",\"foto_url\":null,\"id_area\":5,\"area\":\"Cultivo\",\"id_cargo\":8,\"cargo\":\"Operario\",\"id_tipo_contrato\":4,\"tipo_contrato\":\"Obra o labor\",\"fecha_ingreso\":\"2026-06-01\",\"fecha_retiro\":null,\"estado_empleado\":\"ACTIVO\",\"observaciones\":\"Empleado test\",\"created_at\":\"2026-06-23 10:13:29\",\"updated_at\":null}','{\"id_empleado\":5,\"eliminado\":true}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-23 20:40:07'),(158,8,'EMPLEADOS','CREAR','EMPLEADO',7,NULL,'{\"id_empleado\":7,\"id_tipo_documento\":2,\"tipo_documento\":\"Cédula de ciudadanía\",\"numero_documento\":\"2606232\",\"nombres\":\"Guillermo\",\"apellidos\":\"Mendez\",\"nombre_completo\":\"Guillermo Mendez\",\"correo\":\"Gm@email.com\",\"telefono\":\"3216549874\",\"foto_url\":null,\"id_area\":8,\"area\":\"Calidad\",\"id_cargo\":8,\"cargo\":\"Operario\",\"id_tipo_contrato\":3,\"tipo_contrato\":\"Fijo\",\"fecha_ingreso\":\"2025-02-04\",\"fecha_retiro\":null,\"estado_empleado\":\"ACTIVO\",\"observaciones\":null,\"created_at\":\"2026-06-23 21:29:56\",\"updated_at\":null}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-23 21:29:56'),(159,8,'USUARIOS','CREAR','USUARIO',14,NULL,'{\"id_usuario\":14,\"id_empleado\":7,\"nombre_usuario\":\"GMendez\",\"correo\":\"Gm@email.com\",\"tipo_usuario\":\"EMPLEADO\",\"tipo_autenticacion\":\"LOCAL\",\"requiere_cambio_password\":0,\"correo_verificado\":0,\"estado\":\"ACTIVO\",\"intentos_fallidos\":0,\"fecha_bloqueo\":null,\"ultimo_login\":null,\"created_at\":\"2026-06-23 21:30:53\",\"updated_at\":null,\"nombres\":\"Guillermo\",\"apellidos\":\"Mendez\",\"nombre_completo\":\"Guillermo Mendez\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-23 21:30:53'),(160,8,'USUARIOS','ASIGNAR_ROL','USUARIO',14,NULL,'{\"id_rol\":7}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-23 21:31:14'),(161,13,'AUTENTICACION','LOGOUT','USUARIO_SESION',68,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 21:31:40'),(162,14,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',14,NULL,'{\"correo\":\"Gm@email.com\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 21:31:48'),(163,14,'DOTACIONES','DOTACIONES_MI_TALLA_GUARDAR','DOTACION_TALLA',8,NULL,'{\"id_empleado_dotacion_talla\":8,\"id_empleado\":7,\"id_tipo_dotacion\":3,\"tipo_dotacion\":\"Calzado\",\"id_talla_dotacion\":34,\"talla\":\"36\",\"observaciones\":null}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 21:32:47'),(164,14,'DOTACIONES','DOTACIONES_MI_TALLA_GUARDAR','DOTACION_TALLA',9,NULL,'{\"id_empleado_dotacion_talla\":9,\"id_empleado\":7,\"id_tipo_dotacion\":1,\"tipo_dotacion\":\"Camisa\",\"id_talla_dotacion\":5,\"talla\":\"S\",\"observaciones\":null}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 21:32:47'),(165,14,'DOTACIONES','DOTACIONES_MI_TALLA_GUARDAR','DOTACION_TALLA',10,NULL,'{\"id_empleado_dotacion_talla\":10,\"id_empleado\":7,\"id_tipo_dotacion\":6,\"tipo_dotacion\":\"Delantal\",\"id_talla_dotacion\":7,\"talla\":\"S\",\"observaciones\":null}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 21:32:47'),(166,14,'DOTACIONES','DOTACIONES_MI_TALLA_GUARDAR','DOTACION_TALLA',11,NULL,'{\"id_empleado_dotacion_talla\":11,\"id_empleado\":7,\"id_tipo_dotacion\":7,\"tipo_dotacion\":\"Chaqueta\",\"id_talla_dotacion\":6,\"talla\":\"S\",\"observaciones\":null}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 21:32:47'),(167,14,'DOTACIONES','DOTACIONES_MI_TALLA_GUARDAR','DOTACION_TALLA',12,NULL,'{\"id_empleado_dotacion_talla\":12,\"id_empleado\":7,\"id_tipo_dotacion\":5,\"tipo_dotacion\":\"Gorra\",\"id_talla_dotacion\":49,\"talla\":\"M\",\"observaciones\":null}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 21:32:47'),(168,14,'DOTACIONES','DOTACIONES_MI_TALLA_GUARDAR','DOTACION_TALLA',13,NULL,'{\"id_empleado_dotacion_talla\":13,\"id_empleado\":7,\"id_tipo_dotacion\":4,\"tipo_dotacion\":\"Guantes\",\"id_talla_dotacion\":48,\"talla\":\"S\",\"observaciones\":null}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 21:32:47'),(169,14,'DOTACIONES','DOTACIONES_MI_TALLA_GUARDAR','DOTACION_TALLA',14,NULL,'{\"id_empleado_dotacion_talla\":14,\"id_empleado\":7,\"id_tipo_dotacion\":2,\"tipo_dotacion\":\"Pantalón\",\"id_talla_dotacion\":8,\"talla\":\"S\",\"observaciones\":null}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 21:32:48'),(170,8,'AUTENTICACION','LOGOUT','USUARIO_SESION',71,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-23 22:05:31'),(171,8,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',8,NULL,'{\"correo\":\"Ad@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-23 22:05:47'),(172,8,'DOTACIONES','DOTACIONES_ENTREGA_CREAR','DOTACION_ENTREGA',4,NULL,'{\"request\":{\"id_empleado\":7,\"fecha_entrega\":\"2026-06-24\",\"observaciones\":\"Entrega de dotación completa\",\"detalles\":[{\"id_tipo_dotacion\":3,\"id_talla_dotacion\":32,\"cantidad\":2,\"observaciones\":null},{\"id_tipo_dotacion\":1,\"id_talla_dotacion\":1,\"cantidad\":2,\"observaciones\":null},{\"id_tipo_dotacion\":7,\"id_talla_dotacion\":6,\"cantidad\":2,\"observaciones\":null},{\"id_tipo_dotacion\":6,\"id_talla_dotacion\":15,\"cantidad\":2,\"observaciones\":null},{\"id_tipo_dotacion\":5,\"id_talla_dotacion\":53,\"cantidad\":3,\"observaciones\":null},{\"id_tipo_dotacion\":4,\"id_talla_dotacion\":54,\"cantidad\":1,\"observaciones\":\"entrega temporal\"},{\"id_tipo_dotacion\":2,\"id_talla_dotacion\":16,\"cantidad\":1,\"observaciones\":null}]},\"result\":{\"id_dotacion_entrega\":4}}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-23 22:09:11'),(173,14,'DOTACIONES','DOTACIONES_ENTREGA_CONFIRMAR_RECIBIDO','DOTACION_ENTREGA',4,NULL,'{\"id_usuario\":14,\"id_dotacion_entrega\":4,\"observacion_confirmacion\":\"Recibí en buen estado la dotación completa, pendiente cambio de guantes\",\"firma_url\":null}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 22:09:57'),(174,8,'EMPLEADOS','CREAR','EMPLEADO',8,NULL,'{\"id_empleado\":8,\"id_tipo_documento\":8,\"tipo_documento\":\"Permiso por Protección Temporal - PPT\",\"numero_documento\":\"2606233\",\"nombres\":\"Carlos\",\"apellidos\":\"Agudelo\",\"nombre_completo\":\"Carlos Agudelo\",\"correo\":\"CA@email.com\",\"telefono\":\"3215487963\",\"foto_url\":null,\"id_area\":5,\"area\":\"Cultivo\",\"id_cargo\":8,\"cargo\":\"Operario\",\"id_tipo_contrato\":6,\"tipo_contrato\":\"Aprendizaje\",\"fecha_ingreso\":\"2026-01-05\",\"fecha_retiro\":\"2026-06-25\",\"estado_empleado\":\"ACTIVO\",\"observaciones\":null,\"created_at\":\"2026-06-23 22:13:57\",\"updated_at\":null}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-23 22:13:57'),(175,8,'EMPLEADOS','ACTUALIZAR','EMPLEADO',8,'{\"id_empleado\":8,\"id_tipo_documento\":8,\"tipo_documento\":\"Permiso por Protección Temporal - PPT\",\"numero_documento\":\"2606233\",\"nombres\":\"Carlos\",\"apellidos\":\"Agudelo\",\"nombre_completo\":\"Carlos Agudelo\",\"correo\":\"CA@email.com\",\"telefono\":\"3215487963\",\"foto_url\":\"\\/uploads\\/employees\\/employee_8_20260624031358.png\",\"id_area\":5,\"area\":\"Cultivo\",\"id_cargo\":8,\"cargo\":\"Operario\",\"id_tipo_contrato\":6,\"tipo_contrato\":\"Aprendizaje\",\"fecha_ingreso\":\"2026-01-05\",\"fecha_retiro\":\"2026-06-25\",\"estado_empleado\":\"ACTIVO\",\"observaciones\":null,\"created_at\":\"2026-06-23 22:13:57\",\"updated_at\":\"2026-06-23 22:13:58\"}','{\"id_empleado\":8,\"id_tipo_documento\":8,\"tipo_documento\":\"Permiso por Protección Temporal - PPT\",\"numero_documento\":\"2606233\",\"nombres\":\"Carlos\",\"apellidos\":\"Agudelo\",\"nombre_completo\":\"Carlos Agudelo\",\"correo\":\"CA@email.com\",\"telefono\":\"3215487963\",\"foto_url\":\"\\/uploads\\/employees\\/employee_8_20260624031358.png\",\"id_area\":5,\"area\":\"Cultivo\",\"id_cargo\":8,\"cargo\":\"Operario\",\"id_tipo_contrato\":6,\"tipo_contrato\":\"Aprendizaje\",\"fecha_ingreso\":\"2026-01-05\",\"fecha_retiro\":\"2026-06-25\",\"estado_empleado\":\"RETIRADO\",\"observaciones\":null,\"created_at\":\"2026-06-23 22:13:57\",\"updated_at\":\"2026-06-23 22:14:18\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-23 22:14:18'),(176,8,'EMPLEADOS','ACTUALIZAR','EMPLEADO',8,'{\"id_empleado\":8,\"id_tipo_documento\":8,\"tipo_documento\":\"Permiso por Protección Temporal - PPT\",\"numero_documento\":\"2606233\",\"nombres\":\"Carlos\",\"apellidos\":\"Agudelo\",\"nombre_completo\":\"Carlos Agudelo\",\"correo\":\"CA@email.com\",\"telefono\":\"3215487963\",\"foto_url\":\"\\/uploads\\/employees\\/employee_8_20260624031358.png\",\"id_area\":5,\"area\":\"Cultivo\",\"id_cargo\":8,\"cargo\":\"Operario\",\"id_tipo_contrato\":6,\"tipo_contrato\":\"Aprendizaje\",\"fecha_ingreso\":\"2026-01-05\",\"fecha_retiro\":\"2026-06-25\",\"estado_empleado\":\"RETIRADO\",\"observaciones\":null,\"created_at\":\"2026-06-23 22:13:57\",\"updated_at\":\"2026-06-23 22:14:18\"}','{\"id_empleado\":8,\"id_tipo_documento\":8,\"tipo_documento\":\"Permiso por Protección Temporal - PPT\",\"numero_documento\":\"2606233\",\"nombres\":\"Carlos\",\"apellidos\":\"Agudelo\",\"nombre_completo\":\"Carlos Agudelo\",\"correo\":\"CA@email.com\",\"telefono\":\"3215487963\",\"foto_url\":\"\\/uploads\\/employees\\/employee_8_20260624031358.png\",\"id_area\":5,\"area\":\"Cultivo\",\"id_cargo\":8,\"cargo\":\"Operario\",\"id_tipo_contrato\":6,\"tipo_contrato\":\"Aprendizaje\",\"fecha_ingreso\":\"2026-01-05\",\"fecha_retiro\":\"2026-06-25\",\"estado_empleado\":\"RETIRADO\",\"observaciones\":\"Finalización de contrato, no se renovó.\",\"created_at\":\"2026-06-23 22:13:57\",\"updated_at\":\"2026-06-23 22:14:48\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-23 22:14:48'),(177,8,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',8,NULL,'{\"correo\":\"Ad@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-23 22:42:25'),(178,8,'AUTENTICACION','LOGOUT','USUARIO_SESION',73,NULL,NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-23 22:45:52'),(179,8,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',8,NULL,'{\"correo\":\"Ad@barroblancofarms.com.co\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-24 01:03:35'),(180,8,'CONTRATACION','CONTRATACION_FICHA_GUARDAR','CONTRATACION_FICHA',6,NULL,'{\"id_empleado\":6,\"request\":{\"lugar_nacimiento\":\"Bogota\",\"departamento_nacimiento\":\"Bogota\",\"ciudad_residencia\":\"Zipaquira\",\"departamento_residencia\":\"Cundinamarca\",\"direccion_residencia\":\"CAlle 3 #23 -59\",\"telefono_alterno\":\"8847574\",\"correo_personal\":\"AG@email.com\",\"estado_civil\":\"SOLTERO\",\"nivel_educativo\":\"PROFESIONAL\",\"personas_a_cargo\":2,\"numero_hijos\":1,\"observaciones\":\"ficha de prueba\",\"contacto_emergencia\":{\"nombre_completo\":\"Ana Jimenez\",\"parentesco\":\"Tia\",\"telefono\":\"9874585\",\"telefono_alterno\":\"3194488753\",\"direccion\":\"Calle 35 # 58 - 98\",\"observaciones\":\"No llamar en caso de emergencia\"}},\"result\":{\"id_ficha_ingreso\":1,\"id_empleado\":6,\"estado_ficha\":\"COMPLETA\",\"id_contacto_emergencia\":1}}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-24 01:25:15'),(181,8,'CONTRATACION','CONTRATACION_CONTRATO_CREAR','CONTRATO_EMPLEADO',NULL,NULL,'{\"id_empleado\":6,\"request\":{\"id_tipo_contrato\":4,\"id_area\":2,\"id_cargo\":13,\"fecha_inicio\":\"2026-06-01\",\"fecha_fin\":\"2026-06-30\",\"duracion_meses\":3,\"salario_base\":1400000,\"jornada_laboral\":\"Completa\",\"periodo_prueba_dias\":30,\"estado_contrato\":\"ACTIVO\",\"archivo_contrato_url\":\"https:drive.com\",\"observaciones\":\"NA\"},\"result\":{\"id_empleado_contrato\":1,\"id_empleado\":6,\"estado_contrato\":\"ACTIVO\",\"fecha_inicio\":\"2026-06-01\",\"fecha_fin\":\"2026-06-30\"}}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-24 01:26:04'),(182,8,'CONTRATACION','CONTRATACION_SEGURIDAD_SOCIAL_GUARDAR','SEGURIDAD_SOCIAL_EMPLEADO',6,NULL,'{\"id_empleado\":6,\"request\":{\"id_eps\":1,\"id_arl\":2,\"id_fondo_pension\":1,\"id_fondo_cesantias\":2,\"id_caja_compensacion\":1,\"fecha_afiliacion_eps\":\"2026-01-01\",\"fecha_afiliacion_arl\":\"2026-06-30\",\"fecha_afiliacion_pension\":\"2026-06-01\",\"fecha_afiliacion_cesantias\":\"2026-06-09\",\"fecha_afiliacion_caja\":\"2026-06-05\"},\"result\":{\"id_seguridad_social\":1,\"id_empleado\":6}}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-24 01:26:46'),(183,8,'CONTRATACION','CONTRATACION_EXAMEN_CREAR','EXAMEN_MEDICO_EMPLEADO',NULL,NULL,'{\"id_empleado\":6,\"request\":{\"id_tipo_examen_medico\":1,\"fecha_examen\":\"2026-06-24\",\"entidad_realiza\":\"Compensar\",\"resultado_general\":\"Funcional\",\"fecha_vencimiento\":\"2026-06-25\",\"archivo_url\":\"NA\"},\"result\":{\"id_examen_medico\":1,\"id_empleado\":6,\"id_tipo_examen_medico\":1,\"fecha_examen\":\"2026-06-24\",\"fecha_vencimiento\":\"2026-06-25\"}}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-24 01:27:09'),(184,8,'CONTRATACION','CONTRATACION_DOCUMENTO_REGISTRAR','DOCUMENTO_LABORAL_EMPLEADO',NULL,NULL,'{\"id_empleado\":6,\"request\":{\"id_tipo_documento_laboral\":1,\"nombre_archivo\":\"segurosocial\",\"archivo_url\":\"NA\",\"mime_type\":\"98\",\"peso_bytes\":89,\"fecha_vencimiento\":\"2026-06-26\",\"estado_documento\":\"RECHAZADO\"},\"result\":{\"id_empleado_documento\":1,\"id_empleado\":6,\"id_tipo_documento_laboral\":1,\"estado_documento\":\"RECHAZADO\",\"nombre_archivo\":\"segurosocial\",\"archivo_url\":\"NA\"}}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-24 01:27:42'),(185,8,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',8,NULL,'{\"correo\":\"Ad@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-24 09:08:13'),(186,8,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',8,NULL,'{\"correo\":\"Ad@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-24 11:54:44'),(187,8,'AUTENTICACION','LOGIN_FALLIDO','USUARIO',8,NULL,'{\"motivo\":\"PASSWORD_INCORRECTO\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-24 14:15:24'),(188,8,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',8,NULL,'{\"correo\":\"Ad@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-24 14:15:53'),(189,8,'ASPIRANTES','ASPIRANTE_CREAR','ASPIRANTE',1,NULL,'{\"request\":{\"id_tipo_documento\":2,\"numero_documento\":\"260621\",\"nombres\":\"Ricardo\",\"apellidos\":\"Cardenas\",\"correo\":\"GC@gmail.com\",\"telefono\":\"3216598741\",\"direccion\":\"Cale falsa 123\",\"fecha_nacimiento\":\"2005-01-13\",\"lugar_nacimiento\":\"Bogota D.C\",\"nacionalidad\":\"Colmbiana\",\"id_area_aspira\":5,\"id_cargo_aspira\":8,\"observaciones\":null},\"result\":{\"id_aspirante\":1,\"estado_aspirante\":\"REGISTRADO\"}}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-24 14:22:17'),(190,8,'ASPIRANTES','ASPIRANTE_DOCUMENTO_REGISTRAR','ASPIRANTE_DOCUMENTO',1,NULL,'{\"id_aspirante\":1,\"request\":{\"id_tipo_documento_laboral\":2,\"nombre_archivo\":\"HojaDeVida\",\"archivo_url\":\"https:\\/\\/lavega-cundinamarca.gov.co\\/Ciudadanos\\/RepositorioPQRD\\/Prueba%20Hoja%20de%20Vida.pdf\",\"mime_type\":null,\"peso_bytes\":null,\"estado_documento\":\"CARGADO\",\"observaciones\":null},\"result\":{\"id_aspirante_documento\":1,\"id_aspirante\":1,\"estado_documento\":\"CARGADO\",\"nombre_archivo\":\"HojaDeVida\",\"archivo_url\":\"https:\\/\\/lavega-cundinamarca.gov.co\\/Ciudadanos\\/RepositorioPQRD\\/Prueba%20Hoja%20de%20Vida.pdf\"}}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-24 15:02:30'),(191,8,'ASPIRANTES','ASPIRANTE_DOCUMENTO_REGISTRAR','ASPIRANTE_DOCUMENTO',2,NULL,'{\"id_aspirante\":1,\"request\":{\"id_tipo_documento_laboral\":1,\"nombre_archivo\":\"Documento de identidad\",\"archivo_url\":\"https:\\/\\/tulua.gov.co\\/loader.php?lServicio=Tools2&lTipo=descargas&lFuncion=visorpdf&file=https%3A%2F%2Ftulua.gov.co%2Floader.php%3FlServicio%3DTools2%26lTipo%3Ddescargas%26lFuncion%3DexposeDocument%26idFile%3D11850%26tmp%3D892a149f083b3f6cf071648d2f7f6f39%26urlDeleteFunction%3Dhttps%253A%252F%252Ftulua.gov.co%252Floader.php%253FlServicio%253DTools2%2526lTipo%253Ddescargas%2526lFuncion%253DdeleteTemporalFile%2526tmp%253D892a149f083b3f6cf071648d2f7f6f39&pdf=1&tmp=892a149f083b3f6cf071648d2f7f6f39&fi\",\"mime_type\":null,\"peso_bytes\":null,\"estado_documento\":\"CARGADO\",\"observaciones\":null},\"result\":{\"id_aspirante_documento\":2,\"id_aspirante\":1,\"estado_documento\":\"CARGADO\",\"nombre_archivo\":\"Documento de identidad\",\"archivo_url\":\"https:\\/\\/tulua.gov.co\\/loader.php?lServicio=Tools2&lTipo=descargas&lFuncion=visorpdf&file=https%3A%2F%2Ftulua.gov.co%2Floader.php%3FlServicio%3DTools2%26lTipo%3Ddescargas%26lFuncion%3DexposeDocument%26idFile%3D11850%26tmp%3D892a149f083b3f6cf071648d2f7f6f39%26urlDeleteFunction%3Dhttps%253A%252F%252Ftulua.gov.co%252Floader.php%253FlServicio%253DTools2%2526lTipo%253Ddescargas%2526lFuncion%253DdeleteTemporalFile%2526tmp%253D892a149f083b3f6cf071648d2f7f6f39&pdf=1&tmp=892a149f083b3f6cf071648d2f7f6f39&fi\"}}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-24 15:07:10'),(192,8,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',8,NULL,'{\"correo\":\"Ad@barroblancofarms.com.co\"}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-24 17:18:34'),(193,8,'EMPLEADOS','CREAR','EMPLEADO',9,NULL,'{\"id_empleado\":9,\"id_tipo_documento\":2,\"tipo_documento\":\"Cédula de ciudadanía\",\"numero_documento\":\"2606241\",\"nombres\":\"Camilo\",\"apellidos\":\"Perez\",\"nombre_completo\":\"Camilo Perez\",\"correo\":\"CP@email.com\",\"telefono\":\"3215487951\",\"foto_url\":null,\"id_area\":2,\"area\":\"Administración\",\"id_cargo\":3,\"cargo\":\"Administrador\",\"id_tipo_contrato\":7,\"tipo_contrato\":\"Temporal\",\"fecha_ingreso\":\"2026-06-23\",\"fecha_retiro\":null,\"estado_empleado\":\"ACTIVO\",\"observaciones\":\"User test para ambiente QA\",\"created_at\":\"2026-06-24 17:20:50\",\"updated_at\":null}','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-24 17:20:50'),(194,8,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',8,NULL,'{\"correo\":\"Ad@barroblancofarms.com.co\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-24 17:42:27'),(195,NULL,'AUTENTICACION','LOGIN_FALLIDO','USUARIO',NULL,NULL,'{\"usuario\":\"A2D@barroblancofarms.com.co\",\"motivo\":\"NO_EXISTE\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-24 17:51:09'),(196,8,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',8,NULL,'{\"correo\":\"Ad@barroblancofarms.com.co\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-29 10:54:09'),(197,8,'ASPIRANTES','ASPIRANTE_DOCUMENTO_REGISTRAR','ASPIRANTE_DOCUMENTO',3,NULL,'{\"id_aspirante\":1,\"id_tipo_documento_laboral\":\"2\",\"estado_documento\":\"CARGADO\",\"archivo_url\":null,\"archivo_ruta\":\"uploads\\/applicants\\/1\\/documents\\/20260629_164906_hv-2026.pdf\",\"tipo_origen_archivo\":\"FISICO\",\"result\":{\"id_aspirante_documento\":3,\"id_aspirante\":1,\"estado_documento\":\"CARGADO\",\"nombre_archivo\":\"HV\",\"nombre_original\":\"HV 2026.pdf\",\"archivo_url\":null,\"archivo_ruta\":\"uploads\\/applicants\\/1\\/documents\\/20260629_164906_hv-2026.pdf\",\"mime_type\":\"application\\/pdf\",\"peso_bytes\":151598}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-29 11:49:06'),(198,8,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',8,NULL,'{\"correo\":\"Ad@barroblancofarms.com.co\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 15:35:50'),(199,8,'ASPIRANTES','ASPIRANTE_CREAR','ASPIRANTE',2,NULL,'{\"request\":{\"id_tipo_documento\":2,\"numero_documento\":\"2607091\",\"nombres\":\"Valeria\",\"apellidos\":\"Jimenez\",\"correo\":\"VJ@email.com\",\"telefono\":\"3216549874\",\"direccion\":\"Calle\",\"fecha_nacimiento\":\"2007-06-06\",\"lugar_nacimiento\":\"Zipaquira\",\"nacionalidad\":\"Colombiana\",\"id_area_aspira\":4,\"id_cargo_aspira\":3,\"observaciones\":\"NA\"},\"result\":{\"id_aspirante\":2,\"estado_aspirante\":\"REGISTRADO\"}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 15:41:36'),(200,8,'ASPIRANTES','ASPIRANTE_DOCUMENTO_REGISTRAR','ASPIRANTE_DOCUMENTO',4,NULL,'{\"id_aspirante\":2,\"id_tipo_documento_laboral\":\"2\",\"estado_documento\":\"CARGADO\",\"archivo_url\":null,\"archivo_ruta\":\"uploads\\/applicants\\/2\\/documents\\/20260709_204222_260624-rrhh.pdf\",\"tipo_origen_archivo\":\"FISICO\",\"result\":{\"id_aspirante_documento\":4,\"id_aspirante\":2,\"estado_documento\":\"CARGADO\",\"nombre_archivo\":\"HV\",\"nombre_original\":\"260624 - RRHH.pdf\",\"archivo_url\":null,\"archivo_ruta\":\"uploads\\/applicants\\/2\\/documents\\/20260709_204222_260624-rrhh.pdf\",\"mime_type\":\"application\\/pdf\",\"peso_bytes\":148489}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 15:42:22'),(201,8,'ASPIRANTES','ASPIRANTE_DOCUMENTO_REGISTRAR','ASPIRANTE_DOCUMENTO',5,NULL,'{\"id_aspirante\":2,\"id_tipo_documento_laboral\":1,\"estado_documento\":\"CARGADO\",\"archivo_url\":\"https:\\/\\/urleterna.com\",\"archivo_ruta\":null,\"tipo_origen_archivo\":\"URL\",\"result\":{\"id_aspirante_documento\":5,\"id_aspirante\":2,\"estado_documento\":\"CARGADO\",\"nombre_archivo\":\"CC\",\"nombre_original\":null,\"archivo_url\":\"https:\\/\\/urleterna.com\",\"archivo_ruta\":null,\"mime_type\":null,\"peso_bytes\":null}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 15:43:06'),(202,8,'ASPIRANTES','ASPIRANTE_APROBAR_CONTRATACION','ASPIRANTE',2,NULL,'{\"estado_anterior\":\"REGISTRADO\",\"estado_nuevo\":\"APROBADO_CONTRATACION\",\"result\":{\"id_aspirante\":2,\"estado_anterior\":\"REGISTRADO\",\"estado_nuevo\":\"APROBADO_CONTRATACION\"}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 15:44:33'),(203,8,'ASPIRANTES','ASPIRANTE_CONVERTIR_EMPLEADO','ASPIRANTE',2,NULL,'{\"id_aspirante\":2,\"id_empleado\":10,\"request\":{\"id_tipo_contrato\":4,\"fecha_ingreso\":\"2026-07-09\",\"observaciones\":\"Conversion a empleado\"},\"result\":{\"id_aspirante\":2,\"id_empleado\":10,\"estado_aspirante\":\"CONVERTIDO_EMPLEADO\"}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 15:45:18'),(204,8,'ASPIRANTES','ASPIRANTE_CREAR','ASPIRANTE',3,NULL,'{\"request\":{\"id_tipo_documento\":2,\"numero_documento\":\"2607092\",\"nombres\":\"Alejandro\",\"apellidos\":\"Villalva\",\"correo\":\"AV@email.com\",\"telefono\":\"3216545987\",\"direccion\":\"Calle 4\",\"fecha_nacimiento\":\"2002-06-04\",\"lugar_nacimiento\":\"Zipaquira\",\"nacionalidad\":\"Colombiana\",\"id_area_aspira\":11,\"id_cargo_aspira\":11,\"observaciones\":\"NA\"},\"result\":{\"id_aspirante\":3,\"estado_aspirante\":\"REGISTRADO\"}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 16:23:30'),(205,8,'ASPIRANTES','ASPIRANTE_APROBAR_CONTRATACION','ASPIRANTE',3,NULL,'{\"estado_anterior\":\"REGISTRADO\",\"estado_nuevo\":\"APROBADO_CONTRATACION\",\"result\":{\"id_aspirante\":3,\"estado_anterior\":\"REGISTRADO\",\"estado_nuevo\":\"APROBADO_CONTRATACION\"}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 16:23:36'),(206,8,'ASPIRANTES','ASPIRANTE_CONVERTIR_EMPLEADO','ASPIRANTE',3,NULL,'{\"id_aspirante\":3,\"id_empleado\":11,\"estado_aspirante\":\"CONVERTIDO_EMPLEADO\",\"estado_ficha\":\"INCOMPLETA\",\"request\":{\"id_tipo_contrato\":2,\"fecha_ingreso\":\"2026-07-09\",\"observaciones\":\"Conversion a empleado\"},\"result\":{\"id_aspirante\":3,\"id_empleado\":11,\"estado_aspirante\":\"CONVERTIDO_EMPLEADO\",\"estado_ficha\":\"INCOMPLETA\"}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 16:23:46'),(207,8,'ASPIRANTES','ASPIRANTE_CREAR','ASPIRANTE',4,NULL,'{\"request\":{\"id_tipo_documento\":2,\"numero_documento\":\"260791\",\"nombres\":\"Guillermo\",\"apellidos\":\"Vargas\",\"correo\":\"GV@email.com\",\"telefono\":\"3215487963\",\"direccion\":\"Calle 44\",\"fecha_nacimiento\":\"2003-06-19\",\"lugar_nacimiento\":\"Bogota\",\"departamento_nacimiento\":\"Bogota\",\"nacionalidad\":\"Colombiana\",\"ciudad_residencia\":\"Zipaquira\",\"departamento_residencia\":\"Cundinamarca\",\"estado_civil\":\"CASADO\",\"nivel_educativo\":\"PROFESIONAL\",\"personas_a_cargo\":3,\"numero_hijos\":2,\"id_area_aspira\":5,\"id_cargo_aspira\":5,\"observaciones\":\"Na\"},\"result\":{\"id_aspirante\":4,\"estado_aspirante\":\"REGISTRADO\"}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 17:34:20'),(208,8,'ASPIRANTES','ASPIRANTE_APROBAR_CONTRATACION','ASPIRANTE',4,NULL,'{\"estado_anterior\":\"REGISTRADO\",\"estado_nuevo\":\"APROBADO_CONTRATACION\",\"result\":{\"id_aspirante\":4,\"estado_anterior\":\"REGISTRADO\",\"estado_nuevo\":\"APROBADO_CONTRATACION\"}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 17:34:40'),(209,8,'ASPIRANTES','ASPIRANTE_APROBAR_CONTRATACION','ASPIRANTE',4,NULL,'{\"estado_anterior\":\"APROBADO_CONTRATACION\",\"estado_nuevo\":\"APROBADO_CONTRATACION\",\"result\":{\"id_aspirante\":4,\"estado_anterior\":\"APROBADO_CONTRATACION\",\"estado_nuevo\":\"APROBADO_CONTRATACION\"}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 17:34:43'),(210,8,'ASPIRANTES','ASPIRANTE_CONVERTIR_EMPLEADO','ASPIRANTE',4,NULL,'{\"id_aspirante\":4,\"id_empleado\":12,\"estado_aspirante\":\"CONVERTIDO_EMPLEADO\",\"estado_ficha\":\"INCOMPLETA\",\"request\":{\"id_tipo_contrato\":4,\"fecha_ingreso\":\"2026-07-09\",\"observaciones\":\"Conversion a empleado\"},\"result\":{\"id_aspirante\":4,\"id_empleado\":12,\"estado_aspirante\":\"CONVERTIDO_EMPLEADO\",\"estado_ficha\":\"INCOMPLETA\"}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 17:34:53'),(211,8,'AUTENTICACION','LOGOUT','USUARIO_SESION',84,NULL,NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 19:02:17'),(212,8,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',8,NULL,'{\"correo\":\"Ad@barroblancofarms.com.co\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 19:02:34'),(213,8,'CONTRATACION','CONTRATACION_FICHA_GUARDAR','CONTRATACION_FICHA',12,NULL,'{\"id_empleado\":12,\"request\":{\"lugar_nacimiento\":\"Bogota\",\"departamento_nacimiento\":\"Bogota\",\"ciudad_residencia\":\"Zipaquira\",\"departamento_residencia\":\"Cundinamarca\",\"direccion_residencia\":\"Calle 44\",\"telefono_alterno\":\"3215487963\",\"correo_personal\":\"GV@email.com\",\"estado_civil\":\"CASADO\",\"nivel_educativo\":\"PROFESIONAL\",\"personas_a_cargo\":3,\"numero_hijos\":2,\"observaciones\":\"Ficha creada automáticamente desde aspirante. Na\",\"contacto_emergencia\":{\"nombre_completo\":\"Marley Nandez\",\"parentesco\":\"Prima\",\"telefono\":\"3114578951\",\"telefono_alterno\":\"3215487951\",\"direccion\":\"Calle 54 # 95 - 25\",\"observaciones\":\"NA\"}},\"result\":{\"id_ficha_ingreso\":3,\"id_empleado\":12,\"estado_ficha\":\"COMPLETA\",\"id_contacto_emergencia\":2}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 19:04:02'),(214,8,'CONTRATACION','CONTRATACION_CONTRATO_CREAR','CONTRATO_EMPLEADO',3,NULL,'{\"id_empleado\":12,\"id_tipo_contrato\":4,\"id_plantilla_contrato\":2,\"numero_contrato\":\"1\",\"tipo_cargo_contrato\":\"OPERATIVO\",\"fecha_inicio\":\"2026-07-10\",\"fecha_fin\":\"2026-08-09\",\"request\":{\"id_tipo_contrato\":4,\"id_plantilla_contrato\":2,\"id_area\":5,\"id_cargo\":8,\"fecha_inicio\":\"2026-07-10\",\"fecha_fin\":\"2026-08-09\",\"duracion_meses\":null,\"salario_base\":2000000,\"auxilio_transporte\":true,\"periodo_pago\":\"MENSUAL\",\"lugar_labores\":\"VEREDA SAN JOSE, FINCA BARRO BLANCO\",\"numero_contrato\":\"1\",\"tipo_cargo_contrato\":\"OPERATIVO\",\"objeto_obra_labor\":\"Realizar labores relacionadas con floricultura.\",\"prorroga_dias\":5,\"clausula_funciones\":\"Funciones expecificasa a llevar a cabo\",\"jornada_laboral\":\"44 horas semanales efectivas de labor\",\"periodo_prueba_dias\":null,\"estado_contrato\":null,\"archivo_contrato_url\":null,\"observaciones\":\"NA\"},\"result\":{\"id_empleado_contrato\":3,\"id_empleado\":12,\"id_tipo_contrato\":4,\"id_plantilla_contrato\":2,\"estado_contrato\":\"ACTIVO\"}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 19:10:09'),(215,8,'CONTRATACION','CONTRATACION_CONTRATO_CREAR','CONTRATO_EMPLEADO',4,NULL,'{\"id_empleado\":12,\"id_tipo_contrato\":3,\"id_plantilla_contrato\":1,\"numero_contrato\":\"2\",\"tipo_cargo_contrato\":\"ADMINISTRATIVO\",\"fecha_inicio\":\"2026-07-10\",\"fecha_fin\":\"2026-08-09\",\"request\":{\"id_tipo_contrato\":3,\"id_plantilla_contrato\":1,\"id_area\":8,\"id_cargo\":8,\"fecha_inicio\":\"2026-07-10\",\"fecha_fin\":\"2026-08-09\",\"duracion_meses\":3,\"salario_base\":2000000,\"auxilio_transporte\":false,\"periodo_pago\":\"MENSUAL\",\"lugar_labores\":\"VEREDA SAN JOSE, FINCA BARRO BLANCO\",\"numero_contrato\":\"2\",\"tipo_cargo_contrato\":\"ADMINISTRATIVO\",\"objeto_obra_labor\":null,\"prorroga_dias\":null,\"clausula_funciones\":\"funciones\",\"jornada_laboral\":\"44 horas semanales efectivas de labor\",\"periodo_prueba_dias\":60,\"estado_contrato\":null,\"archivo_contrato_url\":null,\"observaciones\":null},\"result\":{\"id_empleado_contrato\":4,\"id_empleado\":12,\"id_tipo_contrato\":3,\"id_plantilla_contrato\":1,\"estado_contrato\":\"ACTIVO\"}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 19:12:23'),(216,8,'CONTRATACION','CONTRATACION_CONTRATO_CREAR','CONTRATO_EMPLEADO',5,NULL,'{\"id_empleado\":12,\"id_tipo_contrato\":2,\"id_plantilla_contrato\":3,\"numero_contrato\":\"3\",\"tipo_cargo_contrato\":\"ADMINISTRATIVO\",\"fecha_inicio\":\"2026-07-10\",\"fecha_fin\":null,\"request\":{\"id_tipo_contrato\":2,\"id_plantilla_contrato\":3,\"id_area\":2,\"id_cargo\":12,\"fecha_inicio\":\"2026-07-10\",\"fecha_fin\":null,\"duracion_meses\":null,\"salario_base\":2000000,\"auxilio_transporte\":true,\"periodo_pago\":\"MENSUAL\",\"lugar_labores\":\"FINCA BARRO BLANCO GACHANCIPA\",\"numero_contrato\":\"3\",\"tipo_cargo_contrato\":\"ADMINISTRATIVO\",\"objeto_obra_labor\":null,\"prorroga_dias\":null,\"clausula_funciones\":null,\"jornada_laboral\":\"44 horas semanales efectivas de labor\",\"periodo_prueba_dias\":60,\"estado_contrato\":null,\"archivo_contrato_url\":null,\"observaciones\":null},\"result\":{\"id_empleado_contrato\":5,\"id_empleado\":12,\"id_tipo_contrato\":2,\"id_plantilla_contrato\":3,\"estado_contrato\":\"ACTIVO\"}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 19:13:16'),(217,8,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',8,NULL,'{\"correo\":\"Ad@barroblancofarms.com.co\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 20:41:37'),(218,8,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',8,NULL,'{\"correo\":\"Ad@barroblancofarms.com.co\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 20:41:47'),(219,8,'CONTRATACION','CONTRATO_DOCX_GENERAR','CONTRATO_EMPLEADO',5,NULL,'{\"archivo_contrato_url\":\"generated-contracts\\/5\\/contrato-5-260791-20260710-014333.docx\",\"formato\":\"DOCX\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 20:43:36'),(220,8,'CONTRATACION','CONTRATO_DOCX_GENERAR','CONTRATO_EMPLEADO',5,NULL,'{\"archivo_contrato_url\":\"generated-contracts\\/5\\/contrato-5-260791-20260710-014415.docx\",\"formato\":\"DOCX\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 20:44:15'),(221,8,'CONTRATACION','CONTRATO_DOCX_GENERAR','CONTRATO_EMPLEADO',4,NULL,'{\"archivo_contrato_url\":\"generated-contracts\\/4\\/contrato-4-260791-20260710-015016.docx\",\"formato\":\"DOCX\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 20:50:16'),(222,8,'CONTRATACION','CONTRATO_DOCX_GENERAR','CONTRATO_EMPLEADO',3,NULL,'{\"archivo_contrato_url\":\"generated-contracts\\/3\\/contrato-3-260791-20260710-015044.docx\",\"formato\":\"DOCX\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 20:50:45'),(223,1,'CONTRATACION','CONTRATO_DOCX_GENERAR','CONTRATO_EMPLEADO',3,NULL,'{\"archivo_contrato_url\":\"generated-contracts\\/3\\/contrato-3-260791-20260710-015942.docx\",\"formato\":\"DOCX\"}',NULL,NULL,'2026-07-09 20:59:43'),(224,1,'CONTRATACION','CONTRATO_DOCX_GENERAR','CONTRATO_EMPLEADO',3,NULL,'{\"archivo_contrato_url\":\"generated-contracts\\/3\\/contrato-3-260791-20260710-020246.docx\",\"formato\":\"DOCX\"}','127.0.0.1','Copilot Validation','2026-07-09 21:02:47'),(225,8,'CONTRATACION','CONTRATO_DOCX_GENERAR','CONTRATO_EMPLEADO',5,NULL,'{\"archivo_contrato_url\":\"generated-contracts\\/5\\/contrato-5-260791-20260710-020400.docx\",\"formato\":\"DOCX\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 21:04:01'),(226,8,'CONTRATACION','CONTRATO_DOCX_GENERAR','CONTRATO_EMPLEADO',4,NULL,'{\"archivo_contrato_url\":\"generated-contracts\\/4\\/contrato-4-260791-20260710-020411.docx\",\"formato\":\"DOCX\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 21:04:12'),(227,8,'CONTRATACION','CONTRATO_DOCX_GENERAR','CONTRATO_EMPLEADO',3,NULL,'{\"archivo_contrato_url\":\"generated-contracts\\/3\\/contrato-3-260791-20260710-020420.docx\",\"formato\":\"DOCX\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 21:04:20'),(228,1,'CONTRATACION','CONTRATO_DOCX_GENERAR','CONTRATO_EMPLEADO',3,NULL,'{\"archivo_contrato_url\":\"generated-contracts\\/3\\/contrato-3-260791-20260710-022118-1wv9ov.docx\",\"formato\":\"DOCX\"}','127.0.0.1','Copilot Validation','2026-07-09 21:21:18'),(229,8,'CONTRATACION','CONTRATO_DOCX_GENERAR','CONTRATO_EMPLEADO',4,NULL,'{\"archivo_contrato_url\":\"generated-contracts\\/4\\/contrato-4-260791-20260710-022342-awodcc.docx\",\"formato\":\"DOCX\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 21:23:42'),(230,8,'CONTRATACION','CONTRATO_DOCX_GENERAR','CONTRATO_EMPLEADO',3,NULL,'{\"archivo_contrato_url\":\"generated-contracts\\/3\\/contrato-3-260791-20260710-022347-xrrcb8.docx\",\"formato\":\"DOCX\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 21:23:48'),(231,1,'CONTRATACION','CONTRATO_PDF_GENERAR','CONTRATO_EMPLEADO',3,NULL,'{\"id_empleado_contrato\":3,\"archivo_generado_url\":\"generated-contracts\\/3\\/contrato-3-260791-20260710-023711.pdf\",\"user_id\":1}','127.0.0.1','Copilot Validation','2026-07-09 21:37:12'),(232,8,'CONTRATACION','CONTRATO_PDF_GENERAR','CONTRATO_EMPLEADO',5,NULL,'{\"id_empleado_contrato\":5,\"archivo_generado_url\":\"generated-contracts\\/5\\/contrato-5-260791-20260710-024438.pdf\",\"user_id\":8}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 21:44:41'),(233,8,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',8,NULL,'{\"correo\":\"Ad@barroblancofarms.com.co\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-10 09:05:07'),(234,8,'AUTENTICACION','LOGOUT','USUARIO_SESION',89,NULL,NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-10 09:48:58'),(235,8,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',8,NULL,'{\"correo\":\"Ad@barroblancofarms.com.co\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-10 09:49:09'),(236,8,'AUTENTICACION','LOGOUT','USUARIO_SESION',90,NULL,NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-10 09:56:11'),(237,8,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',8,NULL,'{\"correo\":\"Ad@barroblancofarms.com.co\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-10 09:56:23'),(238,8,'AUTENTICACION','LOGOUT','USUARIO_SESION',91,NULL,NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-10 09:56:39'),(239,8,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',8,NULL,'{\"correo\":\"Ad@barroblancofarms.com.co\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-10 09:56:51'),(240,8,'AUTENTICACION','LOGOUT','USUARIO_SESION',92,NULL,NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-10 10:46:38'),(241,8,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',8,NULL,'{\"correo\":\"Ad@barroblancofarms.com.co\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-10 10:47:38'),(242,8,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',8,NULL,'{\"correo\":\"Ad@barroblancofarms.com.co\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-10 12:08:56'),(243,8,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',8,NULL,'{\"correo\":\"Ad@barroblancofarms.com.co\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-10 12:09:34'),(244,8,'AUTENTICACION','LOGOUT','USUARIO_SESION',96,NULL,NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-10 12:28:15'),(245,8,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',8,NULL,'{\"correo\":\"Ad@barroblancofarms.com.co\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-10 12:28:27'),(246,8,'ASPIRANTES','ASPIRANTE_CREAR','ASPIRANTE',5,NULL,'{\"request\":{\"id_tipo_documento\":2,\"numero_documento\":\"1075689456\",\"nombres\":\"carla\",\"apellidos\":\"sanchez\",\"correo\":\"carla@gmail.com\",\"telefono\":\"325365458\",\"direccion\":\"calle4#6-24\",\"fecha_nacimiento\":\"1996-05-20\",\"lugar_nacimiento\":\"chiquinmquira\",\"departamento_nacimiento\":\"boyaca\",\"nacionalidad\":\"colombiana\",\"ciudad_residencia\":\"zipaquira\",\"departamento_residencia\":\"cundinamarca\",\"estado_civil\":\"SOLTERO\",\"nivel_educativo\":\"PROFESIONAL\",\"personas_a_cargo\":2,\"numero_hijos\":2,\"id_area_aspira\":2,\"id_cargo_aspira\":3,\"observaciones\":\"test\"},\"result\":{\"id_aspirante\":5,\"estado_aspirante\":\"REGISTRADO\"}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-10 12:37:06'),(247,8,'ASPIRANTES','ASPIRANTE_DOCUMENTO_REGISTRAR','ASPIRANTE_DOCUMENTO',6,NULL,'{\"id_aspirante\":5,\"id_tipo_documento_laboral\":\"2\",\"estado_documento\":\"CARGADO\",\"archivo_url\":null,\"archivo_ruta\":\"uploads\\/applicants\\/5\\/documents\\/20260710_173819_pdf-test.pdf\",\"tipo_origen_archivo\":\"FISICO\",\"result\":{\"id_aspirante_documento\":6,\"id_aspirante\":5,\"estado_documento\":\"CARGADO\",\"nombre_archivo\":\"hv carla\",\"nombre_original\":\"PDF test.pdf\",\"archivo_url\":null,\"archivo_ruta\":\"uploads\\/applicants\\/5\\/documents\\/20260710_173819_pdf-test.pdf\",\"mime_type\":\"application\\/pdf\",\"peso_bytes\":1196047}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-10 12:38:19'),(248,8,'ASPIRANTES','ASPIRANTE_APROBAR_CONTRATACION','ASPIRANTE',5,NULL,'{\"estado_anterior\":\"REGISTRADO\",\"estado_nuevo\":\"APROBADO_CONTRATACION\",\"result\":{\"id_aspirante\":5,\"estado_anterior\":\"REGISTRADO\",\"estado_nuevo\":\"APROBADO_CONTRATACION\"}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-10 12:39:05'),(249,8,'ASPIRANTES','ASPIRANTE_APROBAR_CONTRATACION','ASPIRANTE',5,NULL,'{\"estado_anterior\":\"APROBADO_CONTRATACION\",\"estado_nuevo\":\"APROBADO_CONTRATACION\",\"result\":{\"id_aspirante\":5,\"estado_anterior\":\"APROBADO_CONTRATACION\",\"estado_nuevo\":\"APROBADO_CONTRATACION\"}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-10 12:39:08'),(250,8,'ASPIRANTES','ASPIRANTE_CONVERTIR_EMPLEADO','ASPIRANTE',5,NULL,'{\"id_aspirante\":5,\"id_empleado\":13,\"estado_aspirante\":\"CONVERTIDO_EMPLEADO\",\"estado_ficha\":\"INCOMPLETA\",\"request\":{\"id_tipo_contrato\":2,\"fecha_ingreso\":\"2026-07-10\",\"observaciones\":\"Conversion a empleado\"},\"result\":{\"id_aspirante\":5,\"id_empleado\":13,\"estado_aspirante\":\"CONVERTIDO_EMPLEADO\",\"estado_ficha\":\"INCOMPLETA\"}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-10 12:39:27'),(251,8,'CONTRATACION','CONTRATACION_CONTRATO_CREAR','CONTRATO_EMPLEADO',6,NULL,'{\"id_empleado\":13,\"id_tipo_contrato\":2,\"id_plantilla_contrato\":3,\"numero_contrato\":\"1\",\"tipo_cargo_contrato\":\"ADMINISTRATIVO\",\"fecha_inicio\":\"2026-07-10\",\"fecha_fin\":null,\"request\":{\"id_tipo_contrato\":2,\"id_plantilla_contrato\":3,\"id_area\":2,\"id_cargo\":3,\"fecha_inicio\":\"2026-07-10\",\"fecha_fin\":null,\"duracion_meses\":null,\"salario_base\":2000000,\"auxilio_transporte\":false,\"periodo_pago\":\"MENSUAL\",\"lugar_labores\":\"FINCA BARRO BLANCO GACHANCIPA\",\"numero_contrato\":\"1\",\"tipo_cargo_contrato\":\"ADMINISTRATIVO\",\"objeto_obra_labor\":null,\"prorroga_dias\":null,\"clausula_funciones\":null,\"jornada_laboral\":\"44 horas semanales efectivas de labor\",\"periodo_prueba_dias\":60,\"estado_contrato\":null,\"archivo_contrato_url\":null,\"observaciones\":null},\"result\":{\"id_empleado_contrato\":6,\"id_empleado\":13,\"id_tipo_contrato\":2,\"id_plantilla_contrato\":3,\"estado_contrato\":\"ACTIVO\"}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-10 12:40:29'),(252,8,'AUTENTICACION','LOGOUT','USUARIO_SESION',97,NULL,NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-10 12:41:40'),(253,8,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',8,NULL,'{\"correo\":\"Ad@barroblancofarms.com.co\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-10 13:19:00'),(254,8,'AUTENTICACION','LOGOUT','USUARIO_SESION',99,NULL,NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-10 14:56:28'),(255,8,'AUTENTICACION','LOGIN_FALLIDO','USUARIO',8,NULL,'{\"motivo\":\"PASSWORD_INCORRECTO\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-10 14:57:31'),(256,8,'AUTENTICACION','LOGIN_EXITOSO','USUARIO',8,NULL,'{\"correo\":\"Ad@barroblancofarms.com.co\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-10 14:57:42');
/*!40000 ALTER TABLE `bbf_log_auditoria` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=59 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_permisos`
--

LOCK TABLES `bbf_permisos` WRITE;
/*!40000 ALTER TABLE `bbf_permisos` DISABLE KEYS */;
INSERT INTO `bbf_permisos` VALUES (1,'DASHBOARD_VER','Ver dashboard','Ver dashboard','DASHBOARD',1,'2026-06-22 16:00:50',NULL),(2,'USUARIOS_VER','Ver usuario','Ver usuario','USUARIOS',1,'2026-06-22 16:00:50',NULL),(3,'USUARIOS_LISTAR','Listar usuarios','Listar usuarios','USUARIOS',1,'2026-06-22 16:00:50',NULL),(4,'USUARIOS_CREAR','Crear usuarios','Crear usuarios','USUARIOS',1,'2026-06-22 16:00:50',NULL),(5,'USUARIOS_EDITAR','Editar usuarios','Editar usuarios','USUARIOS',1,'2026-06-22 16:00:50',NULL),(6,'USUARIOS_INACTIVAR','Inactivar usuarios','Inactivar usuarios','USUARIOS',1,'2026-06-22 16:00:50',NULL),(7,'USUARIOS_CAMBIAR_ESTADO','Cambiar estado de usuarios','Cambiar estado de usuarios','USUARIOS',1,'2026-06-22 16:00:50',NULL),(8,'USUARIOS_ASIGNAR_ROL','Asignar roles a usuarios','Asignar roles a usuarios','USUARIOS',1,'2026-06-22 16:00:50',NULL),(9,'USUARIOS_QUITAR_ROL','Retirar roles de usuarios','Retirar roles de usuarios','USUARIOS',1,'2026-06-22 16:00:50',NULL),(10,'USUARIOS_VER_ROLES','Ver roles de usuarios','Ver roles de usuarios','USUARIOS',1,'2026-06-22 16:00:50',NULL),(11,'USUARIOS_VER_PERMISOS','Ver permisos de usuarios','Ver permisos de usuarios','USUARIOS',1,'2026-06-22 16:00:50',NULL),(12,'ROLES_VER','Ver rol','Ver rol','ROLES',1,'2026-06-22 16:00:50',NULL),(13,'ROLES_LISTAR','Listar roles','Listar roles','ROLES',1,'2026-06-22 16:00:50',NULL),(14,'ROLES_CREAR','Crear roles','Crear roles','ROLES',1,'2026-06-22 16:00:50',NULL),(15,'ROLES_EDITAR','Editar roles','Editar roles','ROLES',1,'2026-06-22 16:00:50',NULL),(16,'PERMISOS_VER','Ver permisos','Ver permisos','PERMISOS',1,'2026-06-22 16:00:50',NULL),(17,'PERMISOS_LISTAR','Listar permisos','Listar permisos','PERMISOS',1,'2026-06-22 16:00:50',NULL),(18,'EMPLEADOS_VER','Ver empleado','Ver detalle de empleado','EMPLEADOS',1,'2026-06-22 16:00:50','2026-06-22 22:34:43'),(19,'EMPLEADOS_LISTAR','Listar empleados','Listar empleados','EMPLEADOS',1,'2026-06-22 22:34:43',NULL),(20,'EMPLEADOS_CREAR','Crear empleado','Crear empleados','EMPLEADOS',1,'2026-06-22 22:34:43',NULL),(21,'EMPLEADOS_EDITAR','Editar empleado','Editar empleados','EMPLEADOS',1,'2026-06-22 22:34:43',NULL),(22,'EMPLEADOS_CAMBIAR_ESTADO','Cambiar estado de empleado','Cambiar estado de empleados','EMPLEADOS',1,'2026-06-22 22:34:43',NULL),(23,'EMPLEADOS_ELIMINAR','Eliminar empleado','Eliminar lógicamente empleados','EMPLEADOS',1,'2026-06-22 22:34:43',NULL),(24,'DOTACIONES_VER','Ver módulo de dotaciones','Permite ver el módulo de dotaciones en el menú','Dotaciones',1,'2026-06-23 11:01:54',NULL),(25,'DOTACIONES_MIS_TALLAS_VER','Ver mis tallas de dotación','Permite al empleado consultar sus tallas de dotación','Dotaciones',1,'2026-06-23 11:01:54',NULL),(26,'DOTACIONES_MIS_TALLAS_EDITAR','Editar mis tallas de dotación','Permite al empleado registrar o actualizar sus tallas de dotación','Dotaciones',1,'2026-06-23 11:01:54',NULL),(27,'DOTACIONES_ADMIN_VER','Ver dotaciones del personal','Permite a RRHH o administrador consultar tallas de empleados','Dotaciones',1,'2026-06-23 11:01:54',NULL),(28,'DOTACIONES_EMPLEADO_VER','Ver tallas de un empleado','Permite consultar las tallas de dotación de un empleado específico','Dotaciones',1,'2026-06-23 11:01:54',NULL),(29,'DOTACIONES_ENTREGAS_VER','Ver entregas de dotación','Permite consultar entregas de dotación realizadas','Dotaciones',1,'2026-06-23 11:01:54',NULL),(30,'DOTACIONES_ENTREGAS_CREAR','Crear entrega de dotación','Permite registrar entregas de dotación al personal','Dotaciones',1,'2026-06-23 11:01:54',NULL),(31,'DOTACIONES_CATALOGOS_VER','Ver catálogos de dotación','Permite consultar tipos y tallas de dotación','Dotaciones',1,'2026-06-23 11:01:54',NULL),(32,'DOTACIONES_MIS_ENTREGAS_VER','Ver mis entregas de dotación','Permite al empleado consultar sus entregas de dotación','Dotaciones',1,'2026-06-23 19:24:43',NULL),(33,'DOTACIONES_MIS_ENTREGAS_CONFIRMAR','Confirmar recibido de dotación','Permite al empleado confirmar que recibió una entrega de dotación','Dotaciones',1,'2026-06-23 19:24:43',NULL),(34,'DOTACIONES_ENTREGAS_ELIMINAR','Eliminar entrega de dotación','Permite eliminar lógicamente una entrega de dotación no confirmada','Dotaciones',1,'2026-06-23 21:36:23',NULL),(35,'CONTRATACION_VER','Ver módulo de contratación','Permite ver el módulo de contratación','Contratación',1,'2026-06-23 22:41:18',NULL),(36,'CONTRATACION_CREAR','Crear ficha de contratación','Permite crear información de contratación del empleado','Contratación',1,'2026-06-23 22:41:18',NULL),(37,'CONTRATACION_EDITAR','Editar ficha de contratación','Permite editar información de contratación del empleado','Contratación',1,'2026-06-23 22:41:18',NULL),(38,'CONTRATACION_ELIMINAR','Eliminar contratación','Permite eliminar lógicamente registros de contratación','Contratación',1,'2026-06-23 22:41:18',NULL),(39,'CONTRATACION_HISTORIAL_VER','Ver historial contractual','Permite consultar historial contractual del empleado','Contratación',1,'2026-06-23 22:41:18',NULL),(40,'CONTRATACION_DOCUMENTOS_VER','Ver documentos de contratación','Permite consultar documentos laborales del empleado','Contratación',1,'2026-06-23 22:41:18',NULL),(41,'CONTRATACION_DOCUMENTOS_SUBIR','Subir documentos de contratación','Permite cargar documentos laborales del empleado','Contratación',1,'2026-06-23 22:41:18',NULL),(42,'CONTRATACION_DOCUMENTOS_VALIDAR','Validar documentos de contratación','Permite validar documentos laborales cargados','Contratación',1,'2026-06-23 22:41:18',NULL),(43,'CONTRATACION_DOCUMENTOS_RECHAZAR','Rechazar documentos de contratación','Permite rechazar documentos laborales cargados','Contratación',1,'2026-06-23 22:41:18',NULL),(44,'CONTRATACION_DOCUMENTOS_ELIMINAR','Eliminar documentos de contratación','Permite eliminar lógicamente documentos laborales','Contratación',1,'2026-06-23 22:41:18',NULL),(45,'CONTRATACION_SEGURIDAD_SOCIAL_VER','Ver seguridad social','Permite consultar seguridad social del empleado','Contratación',1,'2026-06-23 22:41:18',NULL),(46,'CONTRATACION_SEGURIDAD_SOCIAL_EDITAR','Editar seguridad social','Permite registrar o editar seguridad social del empleado','Contratación',1,'2026-06-23 22:41:18',NULL),(47,'CONTRATACION_EXAMENES_VER','Ver exámenes médicos','Permite consultar exámenes médicos del empleado','Contratación',1,'2026-06-23 22:41:18',NULL),(48,'CONTRATACION_EXAMENES_CREAR','Crear examen médico','Permite registrar exámenes médicos del empleado','Contratación',1,'2026-06-23 22:41:18',NULL),(49,'CONTRATACION_EXAMENES_EDITAR','Editar examen médico','Permite editar exámenes médicos del empleado','Contratación',1,'2026-06-23 22:41:18',NULL),(50,'CONTRATACION_ALERTAS_VER','Ver alertas de contratación','Permite consultar alertas de contratos, documentos y exámenes','Contratación',1,'2026-06-23 22:41:18',NULL),(51,'ASPIRANTES_VER','Ver aspirantes','Permite consultar aspirantes','Aspirantes',1,'2026-06-24 13:33:28',NULL),(52,'ASPIRANTES_CREAR','Crear aspirantes','Permite registrar aspirantes','Aspirantes',1,'2026-06-24 13:33:28',NULL),(53,'ASPIRANTES_EDITAR','Editar aspirantes','Permite editar información de aspirantes','Aspirantes',1,'2026-06-24 13:33:28',NULL),(54,'ASPIRANTES_CAMBIAR_ESTADO','Cambiar estado de aspirantes','Permite cambiar el estado del aspirante dentro del proceso','Aspirantes',1,'2026-06-24 13:33:28',NULL),(55,'ASPIRANTES_DOCUMENTOS_VER','Ver documentos de aspirantes','Permite consultar documentos cargados al aspirante','Aspirantes',1,'2026-06-24 13:33:28',NULL),(56,'ASPIRANTES_DOCUMENTOS_SUBIR','Subir documentos de aspirantes','Permite registrar documentos del aspirante','Aspirantes',1,'2026-06-24 13:33:28',NULL),(57,'ASPIRANTES_APROBAR_CONTRATACION','Aprobar aspirante para contratación','Permite aprobar el aspirante para iniciar contratación formal','Aspirantes',1,'2026-06-24 13:33:28',NULL),(58,'ASPIRANTES_CONVERTIR_EMPLEADO','Convertir aspirante en empleado','Permite convertir un aspirante aprobado en empleado','Aspirantes',1,'2026-06-24 13:33:28',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=93 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_rol_permisos`
--

LOCK TABLES `bbf_rol_permisos` WRITE;
/*!40000 ALTER TABLE `bbf_rol_permisos` DISABLE KEYS */;
INSERT INTO `bbf_rol_permisos` VALUES (1,1,1,'2026-06-22 16:00:50'),(2,1,2,'2026-06-22 16:00:50'),(3,1,3,'2026-06-22 16:00:50'),(4,1,4,'2026-06-22 16:00:50'),(5,1,5,'2026-06-22 16:00:50'),(6,1,6,'2026-06-22 16:00:50'),(7,1,7,'2026-06-22 16:00:50'),(8,1,8,'2026-06-22 16:00:50'),(9,1,9,'2026-06-22 16:00:50'),(10,1,10,'2026-06-22 16:00:50'),(11,1,11,'2026-06-22 16:00:50'),(12,1,12,'2026-06-22 16:00:50'),(13,1,13,'2026-06-22 16:00:50'),(14,1,14,'2026-06-22 16:00:50'),(15,1,15,'2026-06-22 16:00:50'),(16,1,16,'2026-06-22 16:00:50'),(17,1,17,'2026-06-22 16:00:50'),(18,1,18,'2026-06-22 16:00:50'),(37,3,1,'2026-06-22 21:58:19'),(38,5,1,'2026-06-22 22:05:57'),(39,6,2,'2026-06-22 22:17:06'),(40,1,19,'2026-06-22 22:42:56'),(41,1,20,'2026-06-22 22:42:56'),(42,1,21,'2026-06-22 22:42:56'),(43,1,22,'2026-06-22 22:42:56'),(44,1,23,'2026-06-22 22:42:56'),(45,1,27,'2026-06-23 11:07:32'),(46,1,31,'2026-06-23 11:07:34'),(47,1,28,'2026-06-23 11:07:37'),(48,1,30,'2026-06-23 11:07:40'),(49,1,29,'2026-06-23 11:07:48'),(50,1,26,'2026-06-23 11:07:52'),(51,1,25,'2026-06-23 11:07:55'),(52,1,24,'2026-06-23 11:07:58'),(54,7,26,'2026-06-23 11:52:30'),(55,7,24,'2026-06-23 11:52:36'),(56,7,25,'2026-06-23 11:52:44'),(57,7,31,'2026-06-23 11:53:33'),(58,7,33,'2026-06-23 20:20:37'),(59,7,29,'2026-06-23 20:21:25'),(60,7,32,'2026-06-23 20:22:46'),(66,1,34,'2026-06-23 22:05:20'),(67,1,33,'2026-06-23 22:05:26'),(68,1,32,'2026-06-23 22:05:28'),(69,1,35,'2026-06-23 22:45:36'),(70,1,36,'2026-06-23 22:45:36'),(71,1,37,'2026-06-23 22:45:36'),(72,1,38,'2026-06-23 22:45:36'),(73,1,39,'2026-06-23 22:45:36'),(74,1,40,'2026-06-23 22:45:36'),(75,1,41,'2026-06-23 22:45:36'),(76,1,42,'2026-06-23 22:45:36'),(77,1,43,'2026-06-23 22:45:36'),(78,1,44,'2026-06-23 22:45:36'),(79,1,45,'2026-06-23 22:45:36'),(80,1,46,'2026-06-23 22:45:36'),(81,1,47,'2026-06-23 22:45:36'),(82,1,48,'2026-06-23 22:45:36'),(83,1,49,'2026-06-23 22:45:36'),(84,1,50,'2026-06-23 22:45:36'),(85,1,51,'2026-06-24 13:35:12'),(86,1,52,'2026-06-24 13:35:12'),(87,1,53,'2026-06-24 13:35:12'),(88,1,54,'2026-06-24 13:35:12'),(89,1,55,'2026-06-24 13:35:12'),(90,1,56,'2026-06-24 13:35:12'),(91,1,57,'2026-06-24 13:35:12'),(92,1,58,'2026-06-24 13:35:12');
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
INSERT INTO `bbf_roles` VALUES (1,'SUPER_ADMIN','Administrador inicial con acceso completo al sistema.',1,0,NULL,'2026-06-22 16:00:50',NULL),(2,'RH_Rol','Rol para recursos humanos',0,1,'2026-06-22 22:07:22','2026-06-22 18:19:32','2026-06-22 22:07:22'),(3,'QA_ROLE_DEBUG_1782183457','debug',0,1,'2026-06-22 21:58:19','2026-06-22 21:57:37','2026-06-22 21:58:19'),(4,'QA_SP_ROLE_1782183872','sp validation',0,1,'2026-06-22 22:06:15','2026-06-22 22:04:32','2026-06-22 22:06:15'),(5,'QA_IRM_ROLE_1782183926','irm validation',0,1,'2026-06-22 22:05:58','2026-06-22 22:05:26','2026-06-22 22:05:58'),(6,'Rol contabilidad','Rol para contabilidad',0,1,'2026-06-23 20:20:24','2026-06-22 22:16:24','2026-06-23 20:20:24'),(7,'EMPLEADO_ROL','Rol para el empleado',1,0,NULL,'2026-06-23 11:52:05',NULL);
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
  CONSTRAINT `FK_BBF_TALLAS_DOTACION_TIPO` FOREIGN KEY (`ID_TIPO_DOTACION`) REFERENCES `bbf_tipos_dotacion` (`ID_TIPO_DOTACION`)
) ENGINE=InnoDB AUTO_INCREMENT=65 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_tallas_dotacion`
--

LOCK TABLES `bbf_tallas_dotacion` WRITE;
/*!40000 ALTER TABLE `bbf_tallas_dotacion` DISABLE KEYS */;
INSERT INTO `bbf_tallas_dotacion` VALUES (1,1,'XS','Extra pequeña',1,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(2,7,'XS','Extra pequeña',1,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(3,6,'XS','Extra pequeña',1,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(4,2,'XS','Extra pequeña',1,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(5,1,'S','Pequeña',2,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(6,7,'S','Pequeña',2,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(7,6,'S','Pequeña',2,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(8,2,'S','Pequeña',2,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(9,1,'M','Mediana',3,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(10,7,'M','Mediana',3,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(11,6,'M','Mediana',3,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(12,2,'M','Mediana',3,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(13,1,'L','Grande',4,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(14,7,'L','Grande',4,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(15,6,'L','Grande',4,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(16,2,'L','Grande',4,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(17,1,'XL','Extra grande',5,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(18,7,'XL','Extra grande',5,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(19,6,'XL','Extra grande',5,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(20,2,'XL','Extra grande',5,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(21,1,'XXL','Doble extra grande',6,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(22,7,'XXL','Doble extra grande',6,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(23,6,'XXL','Doble extra grande',6,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(24,2,'XXL','Doble extra grande',6,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(32,3,'34','Calzado talla 34',34,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(33,3,'35','Calzado talla 35',35,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(34,3,'36','Calzado talla 36',36,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(35,3,'37','Calzado talla 37',37,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(36,3,'38','Calzado talla 38',38,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(37,3,'39','Calzado talla 39',39,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(38,3,'40','Calzado talla 40',40,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(39,3,'41','Calzado talla 41',41,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(40,3,'42','Calzado talla 42',42,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(41,3,'43','Calzado talla 43',43,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(47,5,'S','Pequeña',1,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(48,4,'S','Pequeña',1,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(49,5,'M','Mediana',2,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(50,4,'M','Mediana',2,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(51,5,'L','Grande',3,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(52,4,'L','Grande',3,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(53,5,'Única','Talla única',4,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(54,4,'Única','Talla única',4,1,'2026-06-23 11:01:07','2026-06-23 11:01:22');
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
INSERT INTO `bbf_tipos_contrato` VALUES (1,'QA Contrato','Validacion empleados',1,'2026-06-22 22:43:58',NULL),(2,'Indefinido','Contrato laboral a término indefinido',1,'2026-06-23 10:00:15',NULL),(3,'Fijo','Contrato laboral a término fijo',1,'2026-06-23 10:00:15',NULL),(4,'Obra o labor','Contrato por duración de obra o labor determinada',1,'2026-06-23 10:00:15',NULL),(5,'Prestación de servicios','Contrato civil o comercial por prestación de servicios',1,'2026-06-23 10:00:15',NULL),(6,'Aprendizaje','Contrato de aprendizaje',1,'2026-06-23 10:00:15',NULL),(7,'Temporal','Vinculación temporal o por temporada',1,'2026-06-23 10:00:15',NULL),(8,'Prácticas','Vinculación para prácticas académicas o profesionales',1,'2026-06-23 10:00:15',NULL);
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
INSERT INTO `bbf_tipos_documento` VALUES (1,'QA Cedula',1,'2026-06-22 22:43:58',NULL),(2,'Cédula de ciudadanía',1,'2026-06-23 09:32:04',NULL),(3,'Cédula de extranjería',1,'2026-06-23 09:32:04',NULL),(4,'Tarjeta de identidad',1,'2026-06-23 09:32:04',NULL),(5,'Registro civil',1,'2026-06-23 09:32:04',NULL),(6,'Pasaporte',1,'2026-06-23 09:32:04',NULL),(7,'Permiso Especial de Permanencia - PEP',1,'2026-06-23 09:32:04',NULL),(8,'Permiso por Protección Temporal - PPT',1,'2026-06-23 09:32:04',NULL),(9,'Número de Identificación Tributaria - NIT',1,'2026-06-23 09:32:04',NULL),(10,'Documento Nacional de Identidad extranjero',1,'2026-06-23 09:32:04',NULL),(11,'Otro',1,'2026-06-23 09:32:04',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_tipos_documento_laboral`
--

LOCK TABLES `bbf_tipos_documento_laboral` WRITE;
/*!40000 ALTER TABLE `bbf_tipos_documento_laboral` DISABLE KEYS */;
INSERT INTO `bbf_tipos_documento_laboral` VALUES (1,'Copia de documento de identidad','Documento de identificación del empleado',1,0,1,1,0,1,'2026-06-23 22:40:44','2026-06-24 13:31:10'),(2,'Hoja de vida','Hoja de vida del empleado',1,0,1,1,0,1,'2026-06-23 22:40:44','2026-06-24 13:31:10'),(3,'Contrato firmado','Contrato laboral firmado por las partes',1,1,0,1,0,1,'2026-06-23 22:40:44',NULL),(4,'Afiliación EPS','Soporte de afiliación a EPS',1,0,0,1,0,1,'2026-06-23 22:40:44',NULL),(5,'Afiliación ARL','Soporte de afiliación a ARL',1,0,0,1,0,1,'2026-06-23 22:40:44',NULL),(6,'Afiliación pensión','Soporte de afiliación a fondo de pensión',1,0,0,1,0,1,'2026-06-23 22:40:44',NULL),(7,'Afiliación caja de compensación','Soporte de afiliación a caja de compensación',1,0,0,1,0,1,'2026-06-23 22:40:44',NULL),(8,'Afiliación cesantías','Soporte de afiliación a fondo de cesantías',0,0,0,1,0,1,'2026-06-23 22:40:44',NULL),(9,'Examen médico de ingreso','Soporte del examen médico ocupacional de ingreso',1,1,0,1,0,1,'2026-06-23 22:40:44',NULL),(10,'Certificado bancario','Certificado de cuenta bancaria para pagos',0,0,0,1,0,1,'2026-06-23 22:40:44',NULL),(11,'Certificados de estudio','Soportes académicos del empleado',0,0,1,1,0,1,'2026-06-23 22:40:44','2026-06-24 13:31:10'),(12,'Certificados laborales anteriores','Certificados de experiencia laboral previa',0,0,1,1,0,1,'2026-06-23 22:40:44','2026-06-24 13:31:10'),(13,'RUT','Registro Único Tributario, si aplica',0,0,0,1,0,1,'2026-06-23 22:40:44',NULL),(14,'Otro','Otro documento laboral',0,0,0,1,0,1,'2026-06-23 22:40:44',NULL),(15,'Certificado familiar o personal','Certificados relacionados con hijos, matrimonio u otra información familiar o personal requerida por Recursos Humanos',0,0,1,1,0,1,'2026-06-24 13:31:11',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_tipos_dotacion`
--

LOCK TABLES `bbf_tipos_dotacion` WRITE;
/*!40000 ALTER TABLE `bbf_tipos_dotacion` DISABLE KEYS */;
INSERT INTO `bbf_tipos_dotacion` VALUES (1,'Camisa','Camisa o camiseta institucional',1,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(2,'Pantalón','Pantalón de dotación laboral',1,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(3,'Calzado','Botas o zapatos de trabajo',1,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(4,'Guantes','Guantes de protección',1,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(5,'Gorra','Gorra institucional o de protección solar',1,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(6,'Delantal','Delantal o prenda de protección',1,1,'2026-06-23 11:01:07','2026-06-23 11:01:22'),(7,'Chaqueta','Chaqueta o buzo de dotación',1,1,'2026-06-23 11:01:07','2026-06-23 11:01:22');
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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_usuario_password_historial`
--

LOCK TABLES `bbf_usuario_password_historial` WRITE;
/*!40000 ALTER TABLE `bbf_usuario_password_historial` DISABLE KEYS */;
INSERT INTO `bbf_usuario_password_historial` VALUES (1,1,'$2y$12$WjaxqMT.8TLXM3Pb8D3MsenvcEksMhj7zFEPlumyhUA5h2Zz4f3CW','2026-06-22 16:15:12'),(2,1,'$2y$12$D5IiS1AOtru/JR3u/86Xg.ZhtCjjUuGidYKHowb/qIx5CjbA5n/gW','2026-06-22 16:53:36');
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
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_usuario_roles`
--

LOCK TABLES `bbf_usuario_roles` WRITE;
/*!40000 ALTER TABLE `bbf_usuario_roles` DISABLE KEYS */;
INSERT INTO `bbf_usuario_roles` VALUES (1,1,1,'2026-06-22 16:00:51'),(5,8,1,'2026-06-22 19:31:34'),(7,12,6,'2026-06-22 22:17:16'),(8,13,7,'2026-06-23 11:55:08'),(9,14,7,'2026-06-23 21:31:14');
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
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_usuario_sesiones`
--

LOCK TABLES `bbf_usuario_sesiones` WRITE;
/*!40000 ALTER TABLE `bbf_usuario_sesiones` DISABLE KEYS */;
INSERT INTO `bbf_usuario_sesiones` VALUES (1,1,'d855c674f2315208a4675c8c0edab5350d98bec53d458bb1575b90401bd03454','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 16:02:11','2026-06-29 21:02:11','2026-06-22 16:02:29',0),(2,1,'dcc6d2f5389060a58e80059a455969bbe10ac1c2575c95956197f78336583f2b','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 16:15:10','2026-06-29 21:15:10','2026-06-22 16:16:17',0),(3,1,'d552c82d76f9d7652f78da640c6399cf6e5dfb7264d07c47a833d4e5d4cd6dec','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 16:15:14','2026-06-29 21:15:14','2026-06-22 16:16:17',0),(4,1,'74bb9a07047cf8bf495576d4027c703ebc559a07dee9ef461d393fe99b6f4787','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 16:21:31','2026-06-29 21:21:31','2026-06-22 16:21:41',0),(5,1,'2b21d0b5f758ce3a9d6b0bb6c9fbf3253ef13f5f94bab2a8ff49a33aa02514a9','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 16:35:48','2026-06-29 21:35:48','2026-06-22 16:37:45',0),(6,1,'e8896b7a34539769e646591fc00519249ab5d50093b7701c3e0f7771de1c7707','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 16:43:14','2026-06-29 21:43:14','2026-06-22 16:43:30',0),(7,1,'867b331f196d764759df89898f179712f94025c43c7b279818c03fba8308db4e','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 16:45:08','2026-06-29 21:45:08',NULL,1),(8,1,'ae7e83cf990bc5aa4c9f06c41ed590b04f77f0bc1ce45c80a65f36a8a35a67e6','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 16:45:17','2026-06-29 21:45:17','2026-06-22 16:47:23',0),(9,1,'7949a5ec41d6674a116a8bdfd9f9ef435bd5ea806adf4b7b4126c646bacda9c7','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 16:47:34','2026-06-29 21:47:34','2026-06-22 16:55:58',0),(10,1,'381d4a05611f93ba0b5dd60236ac1839fa92fda66541e333f7440a514dd6e9f9','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 16:53:33','2026-06-29 21:53:33','2026-06-22 16:53:41',0),(11,1,'d7754400a44842f58fa14f0814275d812d188233fd6900f3e442cb20548d0c58','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 16:53:38','2026-06-29 21:53:38','2026-06-22 16:53:41',0),(12,1,'039e52249220b79b5e30fb8e54b83b3507070058109b4033c3c34f211676c003','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 16:59:10','2026-06-29 21:59:10','2026-06-22 17:05:16',0),(13,1,'ef4835568c6b9c7db0d01f17502e9f10d7254c1b762e2174b5ada148b7603c34','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 17:05:16','2026-06-29 22:05:16','2026-06-22 17:33:23',0),(14,1,'35eb79e009483cf1f5f08fba65cc5a2692155c464d222d2decd1f48ebacf32b6','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 17:30:55','2026-06-29 22:30:55','2026-06-22 17:31:05',0),(16,1,'8aaccf8c13a9b19bf9702cad2cfb35edc00190ca14ede024b189c5df4da1e9e0','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 17:34:18','2026-06-29 22:34:18','2026-06-22 17:52:14',0),(17,1,'a9c8398557b04f5a55b828059abe9f9c625e6fce726164338f5682f312a1318d','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 17:52:14','2026-06-29 22:52:14','2026-06-22 18:14:40',0),(18,1,'7c74a5128e93b9819c0aa1d11a7b2077235cb8267a38777751d6dd1b7a3207fa','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 18:18:06','2026-06-29 23:18:06','2026-06-22 18:18:19',0),(19,1,'a57d2c417ad7cc4c230752a4f114b3a376819cf0304feb2447e425527c709ce8','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 18:18:19','2026-06-29 23:18:19','2026-06-22 18:53:30',0),(20,1,'cddb37ca706e702c73b94d8b0542cca4a3e695baed381e112193d085a9b7f5d1','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 18:54:21','2026-06-29 23:54:21','2026-06-22 19:10:19',0),(21,1,'f8cb248ba8a24aee07613271aa67e3fdc5918ba8ba9f91312f1831216790f6e0','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 19:11:57','2026-06-30 00:11:57',NULL,1),(22,1,'073160b1b49b7a9eb7cbbf65b7eb389fbb3cc560d965c22b24dfb9a377a5e0b6','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 19:12:06','2026-06-30 00:12:06','2026-06-22 19:18:03',0),(23,1,'a93061c27b05e4665d1d6d08e30334e268618349e9bfdbdfd1690f35167c63f9','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 19:19:07','2026-06-30 00:19:07','2026-06-22 19:30:39',0),(24,8,'bad09748a6abc090b427fe43d0958fa7b4d32c73d5929ea5530837818d25c8ca','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 19:30:46','2026-06-30 00:30:46','2026-06-22 19:30:53',0),(25,1,'f93b39ac29a24c94af12cc69f616589da2d8151881b665f4d6b142a330a2c3c9','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 19:31:10','2026-06-30 00:31:10','2026-06-22 19:33:07',0),(26,8,'b30cdc90f841d63a889770bc9971505c0f943c94ef199b1ff787bc01defe3e42','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 19:33:19','2026-06-30 00:33:19','2026-06-22 20:50:39',0),(27,1,'cde9d6a135066175767d09473464cdf5bfa4036d1c71bd13f647ce6eb3724682','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 20:44:16','2026-06-30 01:44:16',NULL,1),(28,1,'d638bd69322e16723ccdc6d89869bce8cf8e3545b2d0bbd19e1f08eb07462dec','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 20:45:06','2026-06-30 01:45:06',NULL,1),(29,9,'fadc66cd499f95637c4ec30d56f071dd01d4d3330dead137e84156a16b8f88a1','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 20:45:15','2026-06-30 01:45:15',NULL,1),(30,8,'0c22e17dec5b54cfa872a906caa36822a873d530c57b7ea9e73c60dd2cd999d8','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 20:50:39','2026-06-30 01:50:39','2026-06-22 20:50:43',0),(31,8,'3d454a09a76a90c5939258e4c6b91ec1eebb089a1269e9185a76e1a046397c9e','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 20:51:15','2026-06-30 01:51:15','2026-06-22 22:02:06',0),(32,1,'20ddf913c289822d4e3eb62dd5b56d27e76a83c55f6984c04e72d2db6d7ff744','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 21:20:40','2026-06-30 02:20:40',NULL,1),(33,1,'38f69c89eb47d07288073e5148141caab13e8fddce62b9aa50e6f82e5cd5c85c','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 21:57:09','2026-06-30 02:57:09',NULL,1),(34,1,'c35d2a6a839b18b569020879e272b6e26afc5eb2e164aa937ad2994fffac5ce5','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 21:57:37','2026-06-30 02:57:37',NULL,1),(35,1,'1a0ac45fcba3097bcd0461c85d0580b09670a3662440e28d957951ab93899e6a','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 21:58:15','2026-06-30 02:58:15',NULL,1),(36,8,'caab0f3912981fedbaffb90efb9627627d1fdccdefc8bffac9e325a9277fa797','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 22:02:06','2026-06-30 03:02:06','2026-06-22 22:17:24',0),(37,1,'f15dcfd2e95ad532964688f54e7cded350d427db1abe4b05844568883910094c','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 22:03:42','2026-06-30 03:03:42',NULL,1),(38,1,'9e5ca0b90f5a24eb1a85cc224f7b2265231202f0e7abe4252926accdb440cf03','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 22:03:57','2026-06-30 03:03:57',NULL,1),(39,1,'5e8e48476aad902623bccc0c7b8a1571f3c4eb9a278e5d7d165a0e5f814c87fb','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 22:04:36','2026-06-30 03:04:36',NULL,1),(40,1,'60261d6aece5a914623acaa3d1b9e2c47a9218ff7b5f5fed8a97d54bbd947a36','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 22:05:04','2026-06-30 03:05:04',NULL,1),(41,1,'fa8cecea120270475117206b2c3182466ebab3bf3522c0e2cb671ac8a8d1d6aa','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 22:05:26','2026-06-30 03:05:26',NULL,1),(42,1,'455966e307ca723b299714217c11d6970addd107052b6481b620abc1b7cdfea9','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 22:05:53','2026-06-30 03:05:53',NULL,1),(43,1,'4bfced3a5e1d9fc95fea0c0d51d838b197c3575d9f1ddfa6bf00324afe83ca9a','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 22:06:15','2026-06-30 03:06:15',NULL,1),(44,12,'90ff6dcd1f1fb06e6fd99d03d23ca5f94c05434f703fe77610fa3f517695ceea','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 22:17:53','2026-06-30 03:17:53','2026-06-22 22:18:44',0),(45,1,'eeed87ae463851498c9d5f9484889927a37666799fb80e4a49b8f77f28d22084','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 22:19:39','2026-06-30 03:19:39','2026-06-22 22:53:15',0),(46,1,'768918af6ec3b5bfd3d0bfc66c1d53b82561d3aff93b064c45bea0cc9b1b2e0c','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 22:44:01','2026-06-30 03:44:01',NULL,1),(47,1,'891c820fd6ef8d42668ebc8bb318380603de0dbe843cc30f87ac6e8c3110b43f','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; es-CO) WindowsPowerShell/5.1.19041.6456','2026-06-22 22:51:23','2026-06-30 03:51:23',NULL,1),(48,8,'fb291d38ea70ba1a1644f38394cd5d26f6c168692b25b2c3b6c5ce955e669653','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-22 22:53:30','2026-06-30 03:53:30',NULL,1),(49,8,'fd773559377a13e04e0fd1454eb2c800181ca13fbe4fd6b773670e3ce104963a','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 09:00:47','2026-06-30 14:00:47',NULL,1),(50,8,'979ea8eddb4fb24a0825dbcd043379d50ca5fe7b7d06a3a567ae966207692810','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 09:01:05','2026-06-30 14:01:05','2026-06-23 10:04:18',0),(51,8,'d23e8ab195f620e32139cafff7bc85507275cb4db05bd208f315a3755f1dc352','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 10:04:18','2026-06-30 15:04:18','2026-06-23 10:34:14',0),(52,8,'db8737c3da5d217c72e1e196752fe9d6fb8920e912fbdd6bf0c16e58278fc23a','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 10:34:14','2026-06-30 15:34:14','2026-06-23 10:35:28',0),(53,8,'791a072837b3cfd56233cae03726140cfe94684db9998ddcef200473d24767b9','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 10:35:28','2026-06-30 15:35:28','2026-06-23 10:41:31',0),(54,8,'200273b317382f66a6441d65c6a13944a438cc557a42262a156f990a17025107','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 10:41:31','2026-06-30 15:41:31','2026-06-23 10:41:35',0),(55,8,'44a6ebd32f452d76475f815633940e08b3d63b2ed604e0111da26879eade1015','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 10:41:35','2026-06-30 15:41:35','2026-06-23 11:08:01',0),(56,8,'220be40e053150fc3fb356e00b7883251cff727686127f9e1e15cb87efd8a727','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 11:08:16','2026-06-30 16:08:16',NULL,1),(57,8,'7b805fd9c1ced8020a4e7fb00e92a613aa8f144d659b83b12ebb5dd5d6e4a53b','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 11:49:25','2026-06-30 16:49:25',NULL,1),(58,8,'ddd1fdb2b137eadf1bc84ef1f5a7a3a14c124e3620c65c01565cabead4384045','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 11:49:33','2026-06-30 16:49:33',NULL,1),(59,13,'a6fb7e901e5c891ebca2e480370e38996473ba36d9623994b52396ad2d6293fb','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-23 11:55:37','2026-06-30 16:55:37',NULL,1),(60,8,'91af60714827fb7206b6b4da3882f17d2edcbb9f597f6044f07e8924698fa77e','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 18:12:57','2026-06-30 23:12:57','2026-06-23 19:19:49',0),(61,8,'87a5e8f1895708fbe66607ba379db60d57fb2bce9daa1ca8dca5c53c4af6f652','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 19:19:49','2026-07-01 00:19:49','2026-06-23 19:51:09',0),(62,8,'f23d9e7bc5ee8f8c8129d5dde2222933431ba2a769f790e90af0bac79b475bfc','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-23 20:00:51','2026-07-01 01:00:51','2026-06-23 20:17:33',0),(63,8,'1bf7a8c4bfa97e86cf7c188496416cb16721556a49c3f26816694044b08520d3','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-23 20:17:48','2026-07-01 01:17:48','2026-06-23 20:32:38',0),(64,13,'e6b08535c8a57d240f3017f8e501fcd17913eae2470701c380d1921b095fb37e','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 20:20:06','2026-07-01 01:20:06','2026-06-23 20:20:56',0),(65,13,'f568ebf7e04759792ce07afc124145c96dbff994461b7968f64d97b732351eb2','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 20:21:04','2026-07-01 01:21:04','2026-06-23 20:22:55',0),(66,13,'f7726febe90d0117273680321e2664841953e400d92535a86adee1c53013fd7f','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 20:23:24','2026-07-01 01:23:24','2026-06-23 20:32:56',0),(67,8,'2decb8bd89f57a7817372abb58b3f8a56d96745a0772e74107ae627c5fb9772d','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-23 20:32:50','2026-07-01 01:32:50','2026-06-23 20:44:12',0),(68,13,'d9e74068e5b02e45bd3a2629150c775e7550a9da4e3ad55a91e6b13266828a95','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 20:33:28','2026-07-01 01:33:28','2026-06-23 21:31:40',0),(69,8,'854bb6c4c7299942334e81c26202cf84cf446f8595c1223244a04bfcb0a8e933','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-23 20:44:12','2026-07-01 01:44:12','2026-06-23 21:56:28',0),(70,14,'733e915487011e8dcb06565337b15b7787a62a85e709269294320dc78deb4ffb','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-23 21:31:48','2026-07-01 02:31:48',NULL,1),(71,8,'6ab44603a97f8246ee3aec49461e7757449341f7a560abeefdbe60cb5d00a0a0','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-23 21:56:28','2026-07-01 02:56:28','2026-06-23 22:05:31',0),(72,8,'6e260ab750ea28c1bf020e4089291a6a33b72437585584c9297e62d6f81eac4a','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-23 22:05:47','2026-07-01 03:05:47',NULL,1),(73,8,'1db5518027af746c2d700c9593757ea0fc21c563f6bf5fa4b35962114038101b','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-23 22:42:25','2026-07-01 03:42:25','2026-06-23 22:45:52',0),(74,8,'9c6a2b687a9641fb1ff67fab8ba22aaa5a70fb8bf0d31a8df04bc85ca10da0f4','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-06-24 01:03:35','2026-07-01 06:03:35',NULL,1),(75,8,'f946e40104e1bd089e9dcf82e79e10ed5a2d37faa1bdfa00d994d6c17046e3a0','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-24 09:08:12','2026-07-01 14:08:12','2026-06-24 10:31:14',0),(76,8,'efe9cf902aee3724bbb2c60d69e2fd276794fe8cc9e988536634e4b2d5dfcf29','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-24 10:31:14','2026-07-01 15:31:14',NULL,1),(77,8,'c888ae07e837c7721ae4920ce62c5fe499066e5fac55aa516a805abe3ff116c0','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-24 11:54:44','2026-07-01 16:54:44',NULL,1),(78,8,'6fb138c63e84764c904dfb2c8c99d122ce6c222cb0618dda031038f3fe698c33','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-24 14:15:53','2026-07-01 19:15:53',NULL,1),(79,8,'bdf5dc8979d56b4ea4d7f877ec4b5ba7c278143a3f2688a610afe9447a1e4624','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-24 17:18:34','2026-07-01 22:18:34',NULL,1),(80,8,'d9bb0e92f8a014119e601269a6d04b4f9fb9c78433e490a2ae1cfd027711427f','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-24 17:42:27','2026-07-01 22:42:27',NULL,1),(81,8,'2582a6523be123ce0242c01bdcdf37643ee65220c8264a5ae348c2eb22c4a883','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-29 10:54:09','2026-07-06 15:54:09',NULL,1),(82,8,'944bd71385a25ea801f3063014de1a0507d66e5ccb91ed34fb90d9507301345a','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 15:35:50','2026-07-16 20:35:50','2026-07-09 16:50:36',0),(83,8,'ae73cdd492b98c4d22f1f7b85c32b18b1c642d765490f8625c1e16eefd49c880','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 16:50:36','2026-07-16 21:50:36','2026-07-09 18:55:40',0),(84,8,'8a3de978e4fd94688a1c0dd7db625a9287d3a114577427ff23796ad9a5d950d5','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 18:55:40','2026-07-16 23:55:40','2026-07-09 19:02:17',0),(85,8,'d7a5498843dd447f0620c2dbd3c648c45b02fc342911b15fa05e5a51f74ece0b','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 19:02:34','2026-07-17 00:02:34',NULL,1),(86,8,'8b52a87ed0340eb7111c0433674ca61c8add0b630f12ab3a7df824ca1ab397f4','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 20:41:37','2026-07-17 01:41:37',NULL,1),(87,8,'5d63277db26c4665b471233892ac857e829bd51255f144ab9da8281ebc12f1af','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 20:41:46','2026-07-17 01:41:46','2026-07-09 21:42:21',0),(88,8,'6afd2813c28003c74cec5e8319b8128b8a0e2210dd70afac50ceafbec95e5a2f','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0','2026-07-09 21:42:21','2026-07-17 02:42:21',NULL,1),(89,8,'23a63c9d9c83a1d119b87856ac7bfc9d094c99bb6b298f3fcf32d287b040c46e','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-10 09:05:07','2026-07-17 14:05:07','2026-07-10 09:48:58',0),(90,8,'d01f2834627a99116342166abd0c36e26582ca226ec052abadc954346b1d0c06','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-10 09:49:09','2026-07-17 14:49:09','2026-07-10 09:56:11',0),(91,8,'292d1085d98296747967798dd065c4332214afcde7e5438368a48e6a3dc2c438','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-10 09:56:23','2026-07-17 14:56:23','2026-07-10 09:56:39',0),(92,8,'d21ca5e67968610a510d57f523cf5ed973fd4914967b319f9562c1c1611c24d3','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-10 09:56:51','2026-07-17 14:56:51','2026-07-10 10:46:38',0),(93,8,'f21d1742ac003b41aedeef1c2039076827d6ccb1a949c34b722034857cf2ecb6','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-10 10:47:38','2026-07-17 15:47:38','2026-07-10 12:08:39',0),(94,8,'0c013e0065ee72b24ba50e878175bbdb91c92c27714b15a3619627476bff8bc0','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-10 12:08:39','2026-07-17 17:08:39',NULL,1),(95,8,'1418bdf0363f0dd7b39cf32e729e879ebe85cabddcadb7b305ea8f6b54abd5e7','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-10 12:08:56','2026-07-17 17:08:56',NULL,1),(96,8,'ad41198f540e14078d1799bcfb1c17fe9ce1b5499a2c5c49b64f0b3d8a2b2863','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-10 12:09:34','2026-07-17 17:09:34','2026-07-10 12:28:15',0),(97,8,'64c6cf331b4bde85860c62dbf7d596bea045c5c71f39d1d71a694306076752fa','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-10 12:28:27','2026-07-17 17:28:27','2026-07-10 12:41:40',0),(98,8,'42537ef34883bd6ba57673aa8c69b91185ec9d6e57a4c0fd8dedf3c8d570b76c','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-10 13:19:00','2026-07-17 18:19:00','2026-07-10 14:29:23',0),(99,8,'0f54eba618bb8acb8c8bcc6f0985b0c714dcc747189aa0e8353b4dd4c015e07c','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-10 14:29:23','2026-07-17 19:29:23','2026-07-10 14:56:28',0),(100,8,'b78490fcb78b1af64a1027a3d01620d9463176b53e2286877133abc62111e428','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-10 14:57:42','2026-07-17 19:57:42',NULL,1);
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
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbf_usuarios`
--

LOCK TABLES `bbf_usuarios` WRITE;
/*!40000 ALTER TABLE `bbf_usuarios` DISABLE KEYS */;
INSERT INTO `bbf_usuarios` VALUES (1,NULL,'admin','admin@barroblancofarms.com.co','$2y$12$dVp4yrurlgFNHowqAk35uu4ANXkXCwqEOE16swRIQ6Rzq9C1Sg.1O','ADMIN','LOCAL',0,1,'ACTIVO',0,NULL,'2026-06-22 22:51:23','2026-06-22 16:00:51','2026-06-22 22:51:23'),(5,NULL,'Cardenas Empleado','CE@email.com','$2y$12$Y0UfxvFeMbWWL7X8M5r5bemou440sEpY9mzr0n/OI.id1zmn.vaD6','EMPLEADO','LOCAL',0,0,'ELIMINADO',0,NULL,NULL,'2026-06-22 17:05:11','2026-06-22 21:27:59'),(6,NULL,'Dayana Santafe','RH@barroblancofarms.com.co','$2y$12$uWSSMhZDX/UTkXmX6CLLt.IkekJPo1mXpK/lSer3LX9umAvSBu5na','PERSONAL_AUTORIZADO','LOCAL',1,0,'ELIMINADO',0,NULL,NULL,'2026-06-22 17:07:10','2026-06-22 21:38:30'),(8,NULL,'Super AD','Ad@barroblancofarms.com.co','$2y$12$LkdO0srOxjMeoJnajPDx5.TV5rXXjBJLfSQC/DC27GLIsIfLu/MMO','ADMIN','DOMINIO_EMPRESA',0,0,'ACTIVO',0,NULL,'2026-07-10 14:57:42','2026-06-22 19:28:50','2026-07-10 14:57:42'),(9,NULL,'qa_user_1782179106_edit','qa.user.1782179106@barroblancofarms.com.co','$2y$12$Ab28gJXBfl6IHW/U91JC3unpWbNSjRSxirIpUbYNip0AvO75m.bOu','ADMIN','DOMINIO_EMPRESA',0,1,'ELIMINADO',0,NULL,'2026-06-22 20:45:15','2026-06-22 20:45:08','2026-06-22 21:38:25'),(10,NULL,'qa_deleted_1782181240','qa.deleted.1782181240@barroblancofarms.com.co','$2y$12$Kou5UGQqPN9n0CjL9.U6z.Y1Q2BjBOiQxGXN6R72AYTSfCa79pRpG','ADMIN','LOCAL',0,1,'ELIMINADO',0,NULL,NULL,'2026-06-22 21:20:41','2026-06-22 21:20:42'),(11,NULL,'test','test@email.com','$2y$12$zL5lPeudj/JZbkEfz74mFOfP2ylt0BQREGJExSqsVs/ORAjllIKyW','EMPLEADO','LOCAL',0,0,'ELIMINADO',0,NULL,NULL,'2026-06-22 21:49:47','2026-06-22 21:49:58'),(12,NULL,'ANG','ang@barroblancofarms.com.co','$2y$12$wXdoN1wFV7/fkfl9AeRaUuiMaTPkqrdiE2W2yWODiNtdVIIyQPYZ2','EMPLEADO','DOMINIO_EMPRESA',0,0,'ELIMINADO',0,NULL,'2026-06-22 22:17:53','2026-06-22 22:15:23','2026-06-23 09:56:05'),(13,6,'aGomez','ag@email.com','$2y$12$vx2mEnTzoDYI28qRxLedcusfJaqMuyKNaefT22iGIm3MFIqdt1eVW','EMPLEADO','LOCAL',0,0,'ACTIVO',0,NULL,'2026-06-23 20:33:28','2026-06-23 10:55:38','2026-06-23 20:33:28'),(14,7,'GMendez','Gm@email.com','$2y$12$bJNsMxv7Pbl8z58DxafWxOUMreTw.oSQL1tWIHDXy9dk3RpYzsmKS','EMPLEADO','LOCAL',0,0,'ACTIVO',0,NULL,'2026-06-23 21:31:48','2026-06-23 21:30:53','2026-06-23 21:31:48');
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_AREAS_LISTAR`(
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
CREATE  PROCEDURE `SP_BBF_ASPIRANTES_ACTUALIZAR`(
    IN P_ID_ASPIRANTE INT,
    IN P_ID_TIPO_DOCUMENTO INT,
    IN P_NUMERO_DOCUMENTO VARCHAR(50),
    IN P_NOMBRES VARCHAR(150),
    IN P_APELLIDOS VARCHAR(150),
    IN P_CORREO VARCHAR(150),
    IN P_TELEFONO VARCHAR(50),
    IN P_DIRECCION VARCHAR(250),
    IN P_FECHA_NACIMIENTO DATE,
    IN P_LUGAR_NACIMIENTO VARCHAR(150),
    IN P_DEPARTAMENTO_NACIMIENTO VARCHAR(150),
    IN P_NACIONALIDAD VARCHAR(100),
    IN P_CIUDAD_RESIDENCIA VARCHAR(150),
    IN P_DEPARTAMENTO_RESIDENCIA VARCHAR(150),
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

    SELECT COUNT(*)
    INTO V_EXISTE
    FROM bbf_aspirantes
    WHERE ID_ASPIRANTE = P_ID_ASPIRANTE
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_EXISTE = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El aspirante no existe o fue eliminado.';
    END IF;

    SELECT COUNT(*)
    INTO V_EXISTE
    FROM bbf_aspirantes
    WHERE NUMERO_DOCUMENTO = P_NUMERO_DOCUMENTO
      AND ID_ASPIRANTE <> P_ID_ASPIRANTE
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_EXISTE > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ya existe otro aspirante activo con ese número de documento.';
    END IF;

    IF P_ESTADO_CIVIL IS NOT NULL
       AND P_ESTADO_CIVIL NOT IN ('SOLTERO', 'CASADO', 'UNION_LIBRE', 'SEPARADO', 'DIVORCIADO', 'VIUDO', 'OTRO') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Estado civil no válido.';
    END IF;

    IF P_NIVEL_EDUCATIVO IS NOT NULL
       AND P_NIVEL_EDUCATIVO NOT IN ('PRIMARIA', 'BACHILLER', 'TECNICO', 'TECNOLOGO', 'PROFESIONAL', 'POSGRADO', 'NINGUNO', 'OTRO') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nivel educativo no válido.';
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
        LUGAR_NACIMIENTO = P_LUGAR_NACIMIENTO,
        DEPARTAMENTO_NACIMIENTO = P_DEPARTAMENTO_NACIMIENTO,
        NACIONALIDAD = P_NACIONALIDAD,
        CIUDAD_RESIDENCIA = P_CIUDAD_RESIDENCIA,
        DEPARTAMENTO_RESIDENCIA = P_DEPARTAMENTO_RESIDENCIA,
        ESTADO_CIVIL = P_ESTADO_CIVIL,
        NIVEL_EDUCATIVO = P_NIVEL_EDUCATIVO,
        PERSONAS_A_CARGO = IFNULL(P_PERSONAS_A_CARGO, 0),
        NUMERO_HIJOS = IFNULL(P_NUMERO_HIJOS, 0),
        ID_AREA_ASPIRA = P_ID_AREA_ASPIRA,
        ID_CARGO_ASPIRA = P_ID_CARGO_ASPIRA,
        OBSERVACIONES = P_OBSERVACIONES,
        UPDATED_AT = CURRENT_TIMESTAMP
    WHERE ID_ASPIRANTE = P_ID_ASPIRANTE;

    SELECT
        P_ID_ASPIRANTE AS ID_ASPIRANTE,
        'ACTUALIZADO' AS RESULTADO;
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_ASPIRANTES_CAMBIAR_ESTADO`(
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
CREATE  PROCEDURE `SP_BBF_ASPIRANTES_CONVERTIR_EMPLEADO`(
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

    SELECT COUNT(*)
    INTO V_EXISTE
    FROM bbf_aspirantes
    WHERE ID_ASPIRANTE = P_ID_ASPIRANTE
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_EXISTE = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El aspirante no existe o fue eliminado.';
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

    IF V_ESTADO <> 'APROBADO_CONTRATACION' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El aspirante debe estar en estado APROBADO_CONTRATACION para convertirse en empleado.';
    END IF;

    IF V_ID_EMPLEADO_GENERADO IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El aspirante ya fue convertido en empleado.';
    END IF;

    SELECT COUNT(*)
    INTO V_EXISTE
    FROM bbf_empleados
    WHERE NUMERO_DOCUMENTO = V_NUMERO_DOCUMENTO
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_EXISTE > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ya existe un empleado activo con el documento del aspirante.';
    END IF;

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
        A.ID_ASPIRANTE,
        A.ID_TIPO_DOCUMENTO,
        A.NUMERO_DOCUMENTO,
        A.NOMBRES,
        A.APELLIDOS,
        A.CORREO,
        A.TELEFONO,
        A.ID_AREA_ASPIRA,
        A.ID_CARGO_ASPIRA,
        P_ID_TIPO_CONTRATO,
        IFNULL(P_FECHA_INGRESO, CURRENT_DATE()),
        'ACTIVO',
        CONCAT(
            'Empleado generado desde aspirante. ',
            IFNULL(P_OBSERVACIONES, '')
        )
    FROM bbf_aspirantes A
    WHERE A.ID_ASPIRANTE = P_ID_ASPIRANTE;

    SET V_ID_EMPLEADO_NUEVO = LAST_INSERT_ID();

    INSERT INTO bbf_empleado_ficha_ingreso (
        ID_EMPLEADO,
        FECHA_NACIMIENTO,
        LUGAR_NACIMIENTO,
        DEPARTAMENTO_NACIMIENTO,
        NACIONALIDAD,
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
        A.FECHA_NACIMIENTO,
        A.LUGAR_NACIMIENTO,
        A.DEPARTAMENTO_NACIMIENTO,
        A.NACIONALIDAD,
        A.CIUDAD_RESIDENCIA,
        A.DEPARTAMENTO_RESIDENCIA,
        A.DIRECCION,
        A.TELEFONO,
        A.CORREO,
        A.ESTADO_CIVIL,
        A.NIVEL_EDUCATIVO,
        IFNULL(A.PERSONAS_A_CARGO, 0),
        IFNULL(A.NUMERO_HIJOS, 0),
        'INCOMPLETA',
        CONCAT(
            'Ficha creada automáticamente desde aspirante. ',
            IFNULL(A.OBSERVACIONES, '')
        )
    FROM bbf_aspirantes A
    WHERE A.ID_ASPIRANTE = P_ID_ASPIRANTE;

    SET V_ESTADO_ANTERIOR = V_ESTADO;

    UPDATE bbf_aspirantes
    SET
        ESTADO_ASPIRANTE = 'CONVERTIDO_EMPLEADO',
        ID_EMPLEADO_GENERADO = V_ID_EMPLEADO_NUEVO,
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
        'CONVERTIDO_EMPLEADO',
        IFNULL(P_OBSERVACIONES, 'Aspirante convertido en empleado'),
        P_ID_USUARIO
    );

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
CREATE  PROCEDURE `SP_BBF_ASPIRANTES_CREAR`(
    IN P_ID_TIPO_DOCUMENTO INT,
    IN P_NUMERO_DOCUMENTO VARCHAR(50),
    IN P_NOMBRES VARCHAR(150),
    IN P_APELLIDOS VARCHAR(150),
    IN P_CORREO VARCHAR(150),
    IN P_TELEFONO VARCHAR(50),
    IN P_DIRECCION VARCHAR(250),
    IN P_FECHA_NACIMIENTO DATE,
    IN P_LUGAR_NACIMIENTO VARCHAR(150),
    IN P_DEPARTAMENTO_NACIMIENTO VARCHAR(150),
    IN P_NACIONALIDAD VARCHAR(100),
    IN P_CIUDAD_RESIDENCIA VARCHAR(150),
    IN P_DEPARTAMENTO_RESIDENCIA VARCHAR(150),
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

    SELECT COUNT(*)
    INTO V_EXISTE
    FROM bbf_aspirantes
    WHERE NUMERO_DOCUMENTO = P_NUMERO_DOCUMENTO
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_EXISTE > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ya existe un aspirante activo con ese número de documento.';
    END IF;

    SELECT COUNT(*)
    INTO V_EXISTE
    FROM bbf_empleados
    WHERE NUMERO_DOCUMENTO = P_NUMERO_DOCUMENTO
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_EXISTE > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ya existe un empleado activo con ese número de documento.';
    END IF;

    IF P_ESTADO_CIVIL IS NOT NULL
       AND P_ESTADO_CIVIL NOT IN ('SOLTERO', 'CASADO', 'UNION_LIBRE', 'SEPARADO', 'DIVORCIADO', 'VIUDO', 'OTRO') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Estado civil no válido.';
    END IF;

    IF P_NIVEL_EDUCATIVO IS NOT NULL
       AND P_NIVEL_EDUCATIVO NOT IN ('PRIMARIA', 'BACHILLER', 'TECNICO', 'TECNOLOGO', 'PROFESIONAL', 'POSGRADO', 'NINGUNO', 'OTRO') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nivel educativo no válido.';
    END IF;

    INSERT INTO bbf_aspirantes (
        ID_TIPO_DOCUMENTO,
        NUMERO_DOCUMENTO,
        NOMBRES,
        APELLIDOS,
        CORREO,
        TELEFONO,
        DIRECCION,
        FECHA_NACIMIENTO,
        LUGAR_NACIMIENTO,
        DEPARTAMENTO_NACIMIENTO,
        NACIONALIDAD,
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
        P_LUGAR_NACIMIENTO,
        P_DEPARTAMENTO_NACIMIENTO,
        P_NACIONALIDAD,
        P_CIUDAD_RESIDENCIA,
        P_DEPARTAMENTO_RESIDENCIA,
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_ASPIRANTES_DOCUMENTOS_LISTAR`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_ASPIRANTES_DOCUMENTO_REGISTRAR`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_ASPIRANTES_HISTORIAL_ESTADOS`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_ASPIRANTES_LISTAR`(
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
CREATE  PROCEDURE `SP_BBF_ASPIRANTES_OBTENER`(
    IN P_ID_ASPIRANTE INT
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
        A.DEPARTAMENTO_NACIMIENTO,
        A.NACIONALIDAD,
        A.CIUDAD_RESIDENCIA,
        A.DEPARTAMENTO_RESIDENCIA,
        A.ESTADO_CIVIL,
        A.NIVEL_EDUCATIVO,
        A.PERSONAS_A_CARGO,
        A.NUMERO_HIJOS,
        A.ID_AREA_ASPIRA,
        AR.NOMBRE AS AREA_ASPIRA,
        A.ID_CARGO_ASPIRA,
        C.NOMBRE AS CARGO_ASPIRA,
        A.ESTADO_ASPIRANTE,
        A.OBSERVACIONES,
        A.ID_EMPLEADO_GENERADO,
        A.CREATED_AT,
        A.UPDATED_AT
    FROM bbf_aspirantes A
    LEFT JOIN bbf_tipos_documento TD
        ON TD.ID_TIPO_DOCUMENTO = A.ID_TIPO_DOCUMENTO
    LEFT JOIN bbf_areas AR
        ON AR.ID_AREA = A.ID_AREA_ASPIRA
    LEFT JOIN bbf_cargos C
        ON C.ID_CARGO = A.ID_CARGO_ASPIRA
    WHERE A.ID_ASPIRANTE = P_ID_ASPIRANTE
      AND IFNULL(A.ELIMINADO, 0) = 0
    LIMIT 1;
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_CARGOS_LISTAR`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_CONTRATACION_ALERTAS_LISTAR`(
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
CREATE  PROCEDURE `SP_BBF_CONTRATACION_CONTRATOS_LISTAR`(
    IN P_ID_EMPLEADO INT
)
BEGIN
    SELECT
        EC.ID_EMPLEADO_CONTRATO,
        EC.ID_EMPLEADO,
        EC.ID_TIPO_CONTRATO,
        TC.NOMBRE AS TIPO_CONTRATO,

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
        EC.ID_REGISTRADO_POR,
        EC.CREATED_AT,
        EC.UPDATED_AT,

        CASE
            WHEN EC.FECHA_FIN IS NULL THEN NULL
            ELSE DATEDIFF(EC.FECHA_FIN, CURRENT_DATE())
        END AS DIAS_PARA_VENCER,

        CASE
            WHEN EC.FECHA_FIN IS NULL THEN 'SIN_VENCIMIENTO'
            WHEN EC.FECHA_FIN < CURRENT_DATE() THEN 'VENCIDO'
            WHEN DATEDIFF(EC.FECHA_FIN, CURRENT_DATE()) <= 30 THEN 'PROXIMO_A_VENCER'
            ELSE 'VIGENTE'
        END AS ESTADO_VENCIMIENTO

    FROM bbf_empleado_contratos EC
    LEFT JOIN bbf_tipos_contrato TC
        ON TC.ID_TIPO_CONTRATO = EC.ID_TIPO_CONTRATO
    LEFT JOIN bbf_contrato_plantillas CP
        ON CP.ID_PLANTILLA_CONTRATO = EC.ID_PLANTILLA_CONTRATO
    LEFT JOIN bbf_areas A
        ON A.ID_AREA = EC.ID_AREA
    LEFT JOIN bbf_cargos C
        ON C.ID_CARGO = EC.ID_CARGO
    WHERE EC.ID_EMPLEADO = P_ID_EMPLEADO
      AND IFNULL(EC.ELIMINADO, 0) = 0
    ORDER BY EC.FECHA_INICIO DESC, EC.ID_EMPLEADO_CONTRATO DESC;
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_CONTRATACION_CONTRATO_ARCHIVO_ACTUALIZAR`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_CONTRATACION_CONTRATO_CREAR`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_CONTRATACION_CONTRATO_DATOS_GENERAR`(
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
CREATE  PROCEDURE `SP_BBF_CONTRATACION_DOCUMENTOS_LISTAR`(
    IN P_ID_EMPLEADO INT
)
BEGIN
    SELECT
        D.ID_EMPLEADO_DOCUMENTO,
        D.ID_EMPLEADO,
        D.ID_TIPO_DOCUMENTO_LABORAL,
        TD.NOMBRE AS TIPO_DOCUMENTO_LABORAL,
        TD.OBLIGATORIO,
        TD.REQUIERE_VENCIMIENTO,

        D.NOMBRE_ARCHIVO,
        D.ARCHIVO_URL,
        D.MIME_TYPE,
        D.PESO_BYTES,
        D.FECHA_CARGA,
        D.FECHA_VENCIMIENTO,
        D.ESTADO_DOCUMENTO,
        D.OBSERVACIONES,

        D.ID_CARGADO_POR,
        UC.NOMBRE_USUARIO AS CARGADO_POR,

        D.ID_VALIDADO_POR,
        UV.NOMBRE_USUARIO AS VALIDADO_POR,
        D.FECHA_VALIDACION,

        CASE
            WHEN D.FECHA_VENCIMIENTO IS NOT NULL
             AND D.FECHA_VENCIMIENTO < CURRENT_DATE()
            THEN 1
            ELSE 0
        END AS VENCIDO,

        CASE
            WHEN D.FECHA_VENCIMIENTO IS NOT NULL
             AND D.FECHA_VENCIMIENTO BETWEEN CURRENT_DATE() AND DATE_ADD(CURRENT_DATE(), INTERVAL 30 DAY)
            THEN 1
            ELSE 0
        END AS PROXIMO_VENCER,

        D.CREATED_AT,
        D.UPDATED_AT

    FROM bbf_empleado_documentos D
    INNER JOIN bbf_tipos_documento_laboral TD
        ON TD.ID_TIPO_DOCUMENTO_LABORAL = D.ID_TIPO_DOCUMENTO_LABORAL
    LEFT JOIN bbf_usuarios UC
        ON UC.ID_USUARIO = D.ID_CARGADO_POR
    LEFT JOIN bbf_usuarios UV
        ON UV.ID_USUARIO = D.ID_VALIDADO_POR
    WHERE D.ID_EMPLEADO = P_ID_EMPLEADO
      AND IFNULL(D.ELIMINADO, 0) = 0
    ORDER BY TD.OBLIGATORIO DESC, TD.NOMBRE ASC, D.FECHA_CARGA DESC;
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_CONTRATACION_DOCUMENTO_REGISTRAR`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_CONTRATACION_EXAMENES_LISTAR`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_CONTRATACION_EXAMEN_CREAR`(
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
CREATE  PROCEDURE `SP_BBF_CONTRATACION_FICHA_GUARDAR`(
    IN P_ID_EMPLEADO INT,
    IN P_LUGAR_NACIMIENTO VARCHAR(150),
    IN P_DEPARTAMENTO_NACIMIENTO VARCHAR(150),
    IN P_CIUDAD_RESIDENCIA VARCHAR(150),
    IN P_DEPARTAMENTO_RESIDENCIA VARCHAR(150),
    IN P_DIRECCION_RESIDENCIA VARCHAR(250),
    IN P_TELEFONO_ALTERNO VARCHAR(50),
    IN P_CORREO_PERSONAL VARCHAR(150),
    IN P_ESTADO_CIVIL VARCHAR(50),
    IN P_NIVEL_EDUCATIVO VARCHAR(50),
    IN P_PERSONAS_A_CARGO INT,
    IN P_NUMERO_HIJOS INT,
    IN P_OBSERVACIONES TEXT,

    IN P_CONTACTO_NOMBRE_COMPLETO VARCHAR(200),
    IN P_CONTACTO_PARENTESCO VARCHAR(100),
    IN P_CONTACTO_TELEFONO VARCHAR(50),
    IN P_CONTACTO_TELEFONO_ALTERNO VARCHAR(50),
    IN P_CONTACTO_DIRECCION VARCHAR(250),
    IN P_CONTACTO_OBSERVACIONES VARCHAR(500)
)
BEGIN
    DECLARE V_EXISTE_EMPLEADO INT DEFAULT 0;
    DECLARE V_ID_FICHA INT DEFAULT NULL;
    DECLARE V_ID_CONTACTO INT DEFAULT NULL;
    DECLARE V_ESTADO_FICHA VARCHAR(50);

    SELECT COUNT(*)
    INTO V_EXISTE_EMPLEADO
    FROM bbf_empleados
    WHERE ID_EMPLEADO = P_ID_EMPLEADO
      AND IFNULL(ELIMINADO, 0) = 0;

    IF V_EXISTE_EMPLEADO = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El empleado no existe o fue eliminado.';
    END IF;

    SET V_ESTADO_FICHA =
        CASE
            WHEN P_CIUDAD_RESIDENCIA IS NOT NULL
             AND P_DIRECCION_RESIDENCIA IS NOT NULL
             AND P_CORREO_PERSONAL IS NOT NULL
             AND P_CONTACTO_NOMBRE_COMPLETO IS NOT NULL
             AND P_CONTACTO_TELEFONO IS NOT NULL
            THEN 'COMPLETA'
            ELSE 'INCOMPLETA'
        END;

    SELECT ID_FICHA_INGRESO
    INTO V_ID_FICHA
    FROM bbf_empleado_ficha_ingreso
    WHERE ID_EMPLEADO = P_ID_EMPLEADO
      AND IFNULL(ELIMINADO, 0) = 0
    LIMIT 1;

    IF V_ID_FICHA IS NULL THEN
        INSERT INTO bbf_empleado_ficha_ingreso (
            ID_EMPLEADO,
            LUGAR_NACIMIENTO,
            DEPARTAMENTO_NACIMIENTO,
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
        VALUES (
            P_ID_EMPLEADO,
            P_LUGAR_NACIMIENTO,
            P_DEPARTAMENTO_NACIMIENTO,
            P_CIUDAD_RESIDENCIA,
            P_DEPARTAMENTO_RESIDENCIA,
            P_DIRECCION_RESIDENCIA,
            P_TELEFONO_ALTERNO,
            P_CORREO_PERSONAL,
            P_ESTADO_CIVIL,
            P_NIVEL_EDUCATIVO,
            IFNULL(P_PERSONAS_A_CARGO, 0),
            IFNULL(P_NUMERO_HIJOS, 0),
            V_ESTADO_FICHA,
            P_OBSERVACIONES
        );

        SET V_ID_FICHA = LAST_INSERT_ID();
    ELSE
        UPDATE bbf_empleado_ficha_ingreso
        SET
            LUGAR_NACIMIENTO = P_LUGAR_NACIMIENTO,
            DEPARTAMENTO_NACIMIENTO = P_DEPARTAMENTO_NACIMIENTO,
            CIUDAD_RESIDENCIA = P_CIUDAD_RESIDENCIA,
            DEPARTAMENTO_RESIDENCIA = P_DEPARTAMENTO_RESIDENCIA,
            DIRECCION_RESIDENCIA = P_DIRECCION_RESIDENCIA,
            TELEFONO_ALTERNO = P_TELEFONO_ALTERNO,
            CORREO_PERSONAL = P_CORREO_PERSONAL,
            ESTADO_CIVIL = P_ESTADO_CIVIL,
            NIVEL_EDUCATIVO = P_NIVEL_EDUCATIVO,
            PERSONAS_A_CARGO = IFNULL(P_PERSONAS_A_CARGO, 0),
            NUMERO_HIJOS = IFNULL(P_NUMERO_HIJOS, 0),
            ESTADO_FICHA = V_ESTADO_FICHA,
            OBSERVACIONES = P_OBSERVACIONES,
            UPDATED_AT = CURRENT_TIMESTAMP
        WHERE ID_FICHA_INGRESO = V_ID_FICHA;
    END IF;

    SELECT ID_CONTACTO_EMERGENCIA
    INTO V_ID_CONTACTO
    FROM bbf_empleado_contacto_emergencia
    WHERE ID_EMPLEADO = P_ID_EMPLEADO
      AND IFNULL(ELIMINADO, 0) = 0
    ORDER BY ID_CONTACTO_EMERGENCIA DESC
    LIMIT 1;

    IF P_CONTACTO_NOMBRE_COMPLETO IS NOT NULL OR P_CONTACTO_TELEFONO IS NOT NULL THEN

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

            SET V_ID_CONTACTO = LAST_INSERT_ID();
        ELSE
            UPDATE bbf_empleado_contacto_emergencia
            SET
                NOMBRE_COMPLETO = P_CONTACTO_NOMBRE_COMPLETO,
                PARENTESCO = P_CONTACTO_PARENTESCO,
                TELEFONO = P_CONTACTO_TELEFONO,
                TELEFONO_ALTERNO = P_CONTACTO_TELEFONO_ALTERNO,
                DIRECCION = P_CONTACTO_DIRECCION,
                OBSERVACIONES = P_CONTACTO_OBSERVACIONES,
                UPDATED_AT = CURRENT_TIMESTAMP
            WHERE ID_CONTACTO_EMERGENCIA = V_ID_CONTACTO;
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
CREATE  PROCEDURE `SP_BBF_CONTRATACION_FICHA_OBTENER`(
    IN P_ID_EMPLEADO INT
)
BEGIN
    SELECT
        E.ID_EMPLEADO,
        E.ID_ASPIRANTE_ORIGEN,
        E.NUMERO_DOCUMENTO,
        E.NOMBRES,
        E.APELLIDOS,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS) AS NOMBRE_COMPLETO,
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

        -- Datos personales precargados desde aspirante
        FI.FECHA_NACIMIENTO,
        FI.LUGAR_NACIMIENTO,
        FI.DEPARTAMENTO_NACIMIENTO,
        FI.NACIONALIDAD,
        FI.CIUDAD_RESIDENCIA,
        FI.DEPARTAMENTO_RESIDENCIA,

        -- Datos de residencia y contacto
        FI.DIRECCION_RESIDENCIA,
        FI.TELEFONO_ALTERNO,
        FI.CORREO_PERSONAL,

        -- Información familiar / académica
        FI.ESTADO_CIVIL,
        FI.NIVEL_EDUCATIVO,
        FI.PERSONAS_A_CARGO,
        FI.NUMERO_HIJOS,

        IFNULL(FI.ESTADO_FICHA, 'PENDIENTE') AS ESTADO_FICHA,
        FI.OBSERVACIONES,

        -- Contacto emergencia
        CE.ID_CONTACTO_EMERGENCIA,
        CE.NOMBRE_COMPLETO AS CONTACTO_NOMBRE_COMPLETO,
        CE.PARENTESCO AS CONTACTO_PARENTESCO,
        CE.TELEFONO AS CONTACTO_TELEFONO,
        CE.TELEFONO_ALTERNO AS CONTACTO_TELEFONO_ALTERNO,
        CE.DIRECCION AS CONTACTO_DIRECCION,
        CE.OBSERVACIONES AS CONTACTO_OBSERVACIONES

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
    LEFT JOIN bbf_empleado_contacto_emergencia CE
        ON CE.ID_EMPLEADO = E.ID_EMPLEADO
       AND IFNULL(CE.ELIMINADO, 0) = 0
    WHERE E.ID_EMPLEADO = P_ID_EMPLEADO
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_CONTRATACION_LISTAR_EMPLEADOS`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_CONTRATACION_SEGURIDAD_SOCIAL_GUARDAR`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_CONTRATACION_SEGURIDAD_SOCIAL_OBTENER`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_CONTRATO_PLANTILLAS_LISTAR`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_CONTRATO_PLANTILLA_OBTENER`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_CONTRATO_PLANTILLA_POR_TIPO_OBTENER`(
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
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOMINIOS_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_DOMINIOS_LISTAR`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_DOMINIOS_VALIDAR`(
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
CREATE  PROCEDURE `SP_BBF_DOTACION_EMPLEADOS_LISTAR`(
    IN P_TEXTO_BUSQUEDA VARCHAR(150),
    IN P_ID_AREA INT,
    IN P_ID_CARGO INT
)
BEGIN
    SELECT
        E.ID_EMPLEADO,
        E.NUMERO_DOCUMENTO,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS) AS NOMBRE_COMPLETO,
        E.CORREO,
        E.TELEFONO,
        E.ID_AREA,
        A.NOMBRE AS AREA,
        E.ID_CARGO,
        C.NOMBRE AS CARGO,
        E.ESTADO_EMPLEADO,

        COUNT(DISTINCT DE.ID_DOTACION_ENTREGA) AS TOTAL_ENTREGAS,

        COUNT(DISTINCT CASE
            WHEN DE.ID_DOTACION_ENTREGA IS NOT NULL
             AND DE.FECHA_CONFIRMACION IS NULL
             AND DE.ESTADO = 'REGISTRADA'
            THEN DE.ID_DOTACION_ENTREGA
        END) AS PENDIENTES,

        MAX(DE.FECHA_ENTREGA) AS ULTIMA_ENTREGA,

        GROUP_CONCAT(
            DISTINCT CONCAT(TD.NOMBRE, ': ', IFNULL(T.TALLA, 'Sin talla'))
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
       AND EDT.ID_TIPO_DOTACION = TD.ID_TIPO_DOTACION

    LEFT JOIN bbf_tallas_dotacion T
        ON T.ID_TALLA_DOTACION = EDT.ID_TALLA_DOTACION

    WHERE
        E.ESTADO_EMPLEADO = 'ACTIVO'
        AND IFNULL(E.ELIMINADO, 0) = 0
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
    ORDER BY E.NOMBRES ASC, E.APELLIDOS ASC;
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
CREATE  PROCEDURE `SP_BBF_DOTACION_ENTREGAS_LISTAR`(
    IN P_ID_EMPLEADO INT,
    IN P_FECHA_INICIO DATE,
    IN P_FECHA_FIN DATE
)
BEGIN
    SELECT
        DE.ID_DOTACION_ENTREGA,
        DE.ID_EMPLEADO,
        E.NUMERO_DOCUMENTO,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS) AS NOMBRE_COMPLETO,
        DE.FECHA_ENTREGA,
        DE.FECHA_CONFIRMACION,
        DE.ESTADO,
        DE.OBSERVACIONES,
        DE.OBSERVACION_CONFIRMACION,
        DE.FIRMA_URL,
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
    WHERE
        IFNULL(DE.ELIMINADO, 0) = 0
        AND (P_ID_EMPLEADO IS NULL OR P_ID_EMPLEADO = 0 OR DE.ID_EMPLEADO = P_ID_EMPLEADO)
        AND (P_FECHA_INICIO IS NULL OR DE.FECHA_ENTREGA >= P_FECHA_INICIO)
        AND (P_FECHA_FIN IS NULL OR DE.FECHA_ENTREGA <= P_FECHA_FIN)
    ORDER BY DE.FECHA_ENTREGA DESC, DE.ID_DOTACION_ENTREGA DESC;
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
CREATE  PROCEDURE `SP_BBF_DOTACION_ENTREGA_CONFIRMAR_RECIBIDO`(
    IN P_ID_USUARIO INT,
    IN P_ID_DOTACION_ENTREGA INT,
    IN P_OBSERVACION_CONFIRMACION VARCHAR(500),
    IN P_FIRMA_URL VARCHAR(500)
)
BEGIN
    DECLARE V_ID_EMPLEADO INT;
    DECLARE V_ID_EMPLEADO_ENTREGA INT;
    DECLARE V_ESTADO VARCHAR(50);

    SELECT ID_EMPLEADO
    INTO V_ID_EMPLEADO
    FROM bbf_usuarios
    WHERE ID_USUARIO = P_ID_USUARIO
    LIMIT 1;

    IF V_ID_EMPLEADO IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El usuario no tiene un empleado asociado.';
    END IF;

    SELECT ID_EMPLEADO, ESTADO
    INTO V_ID_EMPLEADO_ENTREGA, V_ESTADO
    FROM bbf_dotacion_entregas
    WHERE ID_DOTACION_ENTREGA = P_ID_DOTACION_ENTREGA
    LIMIT 1;

    IF V_ID_EMPLEADO_ENTREGA IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La entrega de dotación no existe.';
    END IF;

    IF V_ID_EMPLEADO_ENTREGA <> V_ID_EMPLEADO THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No puede confirmar una entrega asociada a otro empleado.';
    END IF;

    IF V_ESTADO = 'ANULADA' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede confirmar una entrega anulada.';
    END IF;

    IF V_ESTADO = 'ENTREGADA' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La entrega ya fue confirmada anteriormente.';
    END IF;

    UPDATE bbf_dotacion_entregas
    SET
        ESTADO = 'ENTREGADA',
        FECHA_CONFIRMACION = CURRENT_TIMESTAMP,
        ID_CONFIRMADO_POR = P_ID_USUARIO,
        OBSERVACION_CONFIRMACION = P_OBSERVACION_CONFIRMACION,
        FIRMA_URL = P_FIRMA_URL
    WHERE ID_DOTACION_ENTREGA = P_ID_DOTACION_ENTREGA;

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
CREATE  PROCEDURE `SP_BBF_DOTACION_ENTREGA_CREAR`(
    IN P_ID_EMPLEADO INT,
    IN P_FECHA_ENTREGA DATE,
    IN P_ID_REGISTRADO_POR INT,
    IN P_OBSERVACIONES TEXT
)
BEGIN
    INSERT INTO bbf_dotacion_entregas (
        ID_EMPLEADO,
        FECHA_ENTREGA,
        ESTADO,
        OBSERVACIONES,
        ID_REGISTRADO_POR
    )
    VALUES (
        P_ID_EMPLEADO,
        P_FECHA_ENTREGA,
        'REGISTRADA',
        P_OBSERVACIONES,
        P_ID_REGISTRADO_POR
    );

    SELECT LAST_INSERT_ID() AS ID_DOTACION_ENTREGA;
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
CREATE  PROCEDURE `SP_BBF_DOTACION_ENTREGA_DETALLE_AGREGAR`(
    IN P_ID_DOTACION_ENTREGA INT,
    IN P_ID_TIPO_DOTACION INT,
    IN P_ID_TALLA_DOTACION INT,
    IN P_CANTIDAD INT,
    IN P_OBSERVACIONES VARCHAR(250)
)
BEGIN
    INSERT INTO bbf_dotacion_entrega_detalle (
        ID_DOTACION_ENTREGA,
        ID_TIPO_DOTACION,
        ID_TALLA_DOTACION,
        CANTIDAD,
        OBSERVACIONES
    )
    VALUES (
        P_ID_DOTACION_ENTREGA,
        P_ID_TIPO_DOTACION,
        P_ID_TALLA_DOTACION,
        IFNULL(P_CANTIDAD, 1),
        P_OBSERVACIONES
    );

    SELECT LAST_INSERT_ID() AS ID_DOTACION_ENTREGA_DETALLE;
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
CREATE  PROCEDURE `SP_BBF_DOTACION_ENTREGA_DETALLE_LISTAR`(
    IN P_ID_DOTACION_ENTREGA INT
)
BEGIN
    SELECT
        DD.ID_DOTACION_ENTREGA_DETALLE,
        DD.ID_DOTACION_ENTREGA,
        DD.ID_TIPO_DOTACION,
        TD.NOMBRE AS TIPO_DOTACION,
        DD.ID_TALLA_DOTACION,
        T.TALLA,
        DD.CANTIDAD,
        DD.OBSERVACIONES,
        DD.CREATED_AT
    FROM bbf_dotacion_entrega_detalle DD
    INNER JOIN bbf_tipos_dotacion TD
        ON TD.ID_TIPO_DOTACION = DD.ID_TIPO_DOTACION
    LEFT JOIN bbf_tallas_dotacion T
        ON T.ID_TALLA_DOTACION = DD.ID_TALLA_DOTACION
    WHERE DD.ID_DOTACION_ENTREGA = P_ID_DOTACION_ENTREGA
    ORDER BY TD.NOMBRE ASC;
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_DOTACION_ENTREGA_ELIMINAR_LOGICO`(
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
CREATE  PROCEDURE `SP_BBF_DOTACION_HISTORIAL_EMPLEADO`(
    IN P_ID_EMPLEADO INT
)
BEGIN
    SELECT
        DE.ID_DOTACION_ENTREGA,
        DE.ID_EMPLEADO,
        E.NUMERO_DOCUMENTO,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS) AS NOMBRE_COMPLETO,
        A.NOMBRE AS AREA,
        C.NOMBRE AS CARGO,

        DE.FECHA_ENTREGA,
        DE.FECHA_CONFIRMACION,
        DE.ESTADO,
        DE.OBSERVACIONES AS OBSERVACIONES_ENTREGA,
        DE.OBSERVACION_CONFIRMACION,
        DE.FIRMA_URL,

        DE.ID_REGISTRADO_POR,
        UR.NOMBRE_USUARIO AS REGISTRADO_POR,
        DE.ID_CONFIRMADO_POR,
        UC.NOMBRE_USUARIO AS CONFIRMADO_POR,

        DD.ID_DOTACION_ENTREGA_DETALLE,
        DD.ID_TIPO_DOTACION,
        TD.NOMBRE AS TIPO_DOTACION,
        DD.ID_TALLA_DOTACION,
        T.TALLA,
        DD.CANTIDAD,
        DD.OBSERVACIONES AS OBSERVACIONES_DETALLE,

        DE.CREATED_AT,
        DE.UPDATED_AT
    FROM bbf_dotacion_entregas DE
    INNER JOIN bbf_empleados E
        ON E.ID_EMPLEADO = DE.ID_EMPLEADO
    LEFT JOIN bbf_areas A
        ON A.ID_AREA = E.ID_AREA
    LEFT JOIN bbf_cargos C
        ON C.ID_CARGO = E.ID_CARGO
    LEFT JOIN bbf_usuarios UR
        ON UR.ID_USUARIO = DE.ID_REGISTRADO_POR
    LEFT JOIN bbf_usuarios UC
        ON UC.ID_USUARIO = DE.ID_CONFIRMADO_POR
    INNER JOIN bbf_dotacion_entrega_detalle DD
        ON DD.ID_DOTACION_ENTREGA = DE.ID_DOTACION_ENTREGA
    INNER JOIN bbf_tipos_dotacion TD
        ON TD.ID_TIPO_DOTACION = DD.ID_TIPO_DOTACION
    LEFT JOIN bbf_tallas_dotacion T
        ON T.ID_TALLA_DOTACION = DD.ID_TALLA_DOTACION
    WHERE DE.ID_EMPLEADO = P_ID_EMPLEADO
      AND IFNULL(DE.ELIMINADO, 0) = 0
      AND IFNULL(DD.ELIMINADO, 0) = 0
    ORDER BY DE.FECHA_ENTREGA DESC, DE.ID_DOTACION_ENTREGA DESC, TD.NOMBRE ASC;
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
CREATE  PROCEDURE `SP_BBF_DOTACION_MIS_ENTREGAS_LISTAR`(
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
        SET MESSAGE_TEXT = 'El usuario no tiene un empleado asociado.';
    END IF;

    SELECT
        DE.ID_DOTACION_ENTREGA,
        DE.ID_EMPLEADO,
        E.NUMERO_DOCUMENTO,
        CONCAT(E.NOMBRES, ' ', E.APELLIDOS) AS NOMBRE_COMPLETO,
        DE.FECHA_ENTREGA,
        DE.FECHA_CONFIRMACION,
        DE.ESTADO,
        DE.OBSERVACIONES,
        DE.OBSERVACION_CONFIRMACION,
        DE.FIRMA_URL,
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
    WHERE DE.ID_EMPLEADO = V_ID_EMPLEADO
      AND IFNULL(DE.ELIMINADO, 0) = 0
    ORDER BY DE.FECHA_ENTREGA DESC, DE.ID_DOTACION_ENTREGA DESC;
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
CREATE  PROCEDURE `SP_BBF_DOTACION_MIS_TALLAS_LISTAR`(
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
        SET MESSAGE_TEXT = 'El usuario no tiene un empleado asociado.';
    END IF;

    SELECT
        TD.ID_TIPO_DOTACION,
        TD.NOMBRE AS TIPO_DOTACION,
        TD.DESCRIPCION AS TIPO_DOTACION_DESCRIPCION,
        TD.REQUIERE_TALLA,
        EDT.ID_EMPLEADO_DOTACION_TALLA,
        EDT.ID_EMPLEADO,
        EDT.ID_TALLA_DOTACION,
        T.TALLA,
        T.DESCRIPCION AS TALLA_DESCRIPCION,
        EDT.OBSERVACIONES,
        EDT.CREATED_AT,
        EDT.UPDATED_AT
    FROM bbf_tipos_dotacion TD
    LEFT JOIN bbf_empleado_dotacion_tallas EDT
        ON EDT.ID_TIPO_DOTACION = TD.ID_TIPO_DOTACION
       AND EDT.ID_EMPLEADO = V_ID_EMPLEADO
    LEFT JOIN bbf_tallas_dotacion T
        ON T.ID_TALLA_DOTACION = EDT.ID_TALLA_DOTACION
    WHERE TD.ACTIVO = 1
    ORDER BY TD.NOMBRE ASC;
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_DOTACION_MI_TALLA_GUARDAR`(
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
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_DOTACION_TALLAS_EMPLEADO_LISTAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_DOTACION_TALLAS_EMPLEADO_LISTAR`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_DOTACION_TALLAS_LISTAR`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_DOTACION_TIPOS_LISTAR`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_EMPLEADOS_ACTUALIZAR`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_EMPLEADOS_CAMBIAR_ESTADO`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_EMPLEADOS_CREAR`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_EMPLEADOS_ELIMINAR`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_EMPLEADOS_LISTAR`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_EMPLEADOS_OBTENER_POR_DOCUMENTO`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_EMPLEADOS_OBTENER_POR_ID`(
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
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_LOGIN_MARCAR_EXITOSO` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_LOGIN_MARCAR_EXITOSO`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_LOGIN_MARCAR_FALLIDO`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_LOGIN_OBTENER_USUARIO`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_LOG_AUDITORIA_CREAR`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_LOG_AUDITORIA_LISTAR`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_LOG_AUDITORIA_OBTENER_POR_ID`(
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
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_PASSWORD_RESET_CREAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_PASSWORD_RESET_CREAR`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_PASSWORD_RESET_MARCAR_USADO`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_PASSWORD_RESET_OBTENER`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_PERMISOS_LISTAR`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_ROLES_CAMBIAR_ESTADO`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_ROLES_CREAR`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_ROLES_ELIMINAR`(
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
CREATE  PROCEDURE `SP_BBF_ROLES_LISTAR`(IN P_SOLO_ACTIVOS TINYINT)
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_ROL_OBTENER_PERMISOS`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_ROL_PERMISOS_ASIGNAR`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_ROL_PERMISOS_QUITAR`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_TIPOS_CONTRATO_LISTAR`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_TIPOS_DOCUMENTO_LABORAL_LISTAR`(
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
CREATE  PROCEDURE `SP_BBF_TIPOS_DOCUMENTO_LISTAR`(IN P_SOLO_ACTIVOS TINYINT)
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
/*!50003 DROP PROCEDURE IF EXISTS `SP_BBF_USUARIOS_ACTUALIZAR` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_USUARIOS_ACTUALIZAR`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_USUARIOS_CAMBIAR_ESTADO`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_USUARIOS_CAMBIAR_PASSWORD`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_USUARIOS_CREAR`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_USUARIOS_CREAR_POR_DOCUMENTO`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_USUARIOS_LISTAR`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_USUARIOS_OBTENER_POR_ID`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_USUARIO_OBTENER_PERMISOS`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_USUARIO_OBTENER_ROLES`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_USUARIO_ROLES_ASIGNAR`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_USUARIO_ROLES_QUITAR`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_USUARIO_SESIONES_CREAR`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_USUARIO_SESIONES_OBTENER_POR_TOKEN`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_USUARIO_SESIONES_REVOCAR`(
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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `SP_BBF_USUARIO_SESIONES_REVOCAR_TODAS`(
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

-- Dump completed on 2026-07-10 16:37:55
