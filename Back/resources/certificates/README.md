# Recursos del certificado F-002

`bbf-logo.jpeg` es la imagen original `word/media/image2.jpeg` del Word BBTH-F-002 suministrado por el usuario. Se incluye como recurso de aplicación para no depender de una ruta de Google Drive ni del Word durante la generación. La marca de agua reutiliza el logo con opacidad PDF reducida, sin modificar la imagen.

`helvetica-widths.php` contiene las métricas estándar de Helvetica y Helvetica-Bold para Windows-1252 (unidades de 1/1000 em), obtenidas con ReportLab durante la implementación. ReportLab no es una dependencia de ejecución: PHP utiliza directamente estas tablas para ajustar las líneas a su ancho real.

El cuerpo y los firmantes se obtienen exclusivamente del servicio validado. El control documental utiliza `formato.control_documental` con claves `motivo_revision`, `elaboro`, `reviso`, `aprobo`; valores de texto. Los nombres del Word no se usan como firmantes ni aprobadores predeterminados.
