---
title: 'Corregir el PDF del certificado F-002'
type: 'bugfix'
created: '2026-10-09'
status: 'done'
route: 'oneshot'
context: []
---

<frozen-after-approval>

## Intent

Corregir el certificado laboral que se ve en blanco y generar un PDF legible con los datos oficiales y la estructura de la primera plantilla del Word F-002 suministrado. Conservar y continuar los cambios locales existentes, según autorización explícita del usuario. Incluir identificación, ingreso, cargo, todas las funciones y firmante configurado; cabecera institucional, control documental y paginación real. No copiar datos de personas del ejemplo, alterar BD ni implementar las otras variantes del Word.

</frozen-after-approval>

## Implementation Notes

- Investigación Front/Back/BD: la descarga binaria y las validaciones del servicio funcionan; el renderizador deja activo el color claro del fondo y todo texto hereda ese color. No hay separación de líneas ni paginación; se cortan funciones después de 14.
- Cambio reversible y acotado: `Back/app/Services/CertificateRenderer.php`, recursos de logo/métricas del certificado y pruebas `Back/tests/Unit/CertificateRendererTest.php` y `Back/tests/Feature/CertificateApiTest.php` si es necesario.
- Reutilizar contexto validado y SP existentes. Fecha de expedición de la empresa distinta de lugar de expedición del documento del empleado. Fechas legibles en español. No sustituir los cambios ajenos ni registrar emisiones.
- Verificar texto negro explícito, PDF válido, datos completos, nombres/funciones extensos, logo y encabezado/pie en todas las páginas mediante PHPUnit y renderizado Poppler. El Word local suministrado conserva cabecera con logo y marca de agua; usar su estructura, adaptando paginación al contenido real.
- Implementado texto negro, papel carta, logo original con proporción conservada y marca de agua; cabecera/código/versión/vigencia, cuerpo de la primera variante, fechas en español, todos los firmantes y funciones sin truncamiento, ajuste con métricas Helvetica y paginación dinámica. Diferenciar ciudad institucional y expedición de documento.
- Firma indivisible y sangría francesa de funciones. Metadatos/controles que exceden espacio y caracteres ajenos a Windows-1252 se rechazan con 422 explícito, sin PDF alterado. Los responsables de control no configurados se muestran con raya, sin copiar nombres del Word; pendiente configuración institucional fuera del alcance de cambios de BD.
- Verificación final: PHPUnit CertificateRendererTest + CertificateApiTest, 23 pruebas/794 aserciones correctas. Pint aplicado a los tres archivos PHP del certificado. PDFPlumber recuperó todas las palabras de 10 y 30 funciones en muestras de 2 y 4 páginas, verificó color negro, márgenes y control en cada página. Poppler produjo seis imágenes; inspección visual completada.
- Pruebas ampliadas de ContractingApiTest detectaron cuatro fallos en mocks de lugar de expedición/salario mínimo y limpieza de firma, sin cambios de esta tarea en sus rutas/implementaciones. Front test no llegó a ejecutarse por referencias preexistentes a createExam() en contracting-medical-exams.component.spec.ts (líneas 95 y 110). No se modifican esos flujos para ocultar fallos.
- Se registra en commit el renderer, recursos, pruebas unitarias y esta especificación. Las rutas, servicio, controlador y otras modificaciones previas permanecen en el árbol de trabajo; no se publica ni se incorpora indiscriminadamente trabajo ajeno.

## Review Triage Log

1. medium, patch: encabezado no limitaba altura; celdas ajustan fuente y rechazan exceso con 422.
2. medium, patch: pie sin límite invadía cuerpo; altura máxima verificable con prueba de regresión.
3. medium, patch: sustitución silenciosa de caracteres; comparación de ida/vuelta y 422. Español, tildes y ñ se conservan. Fuente Unicode amplia queda para un alcance distinto.
4. low, patch: logo deformado; proporción original 998/557 conservada.
5. medium, patch: firma demasiado extensa se partía; firma indivisible y error si supera una página.
6. low, patch: introducción de funciones huérfana; reserva 26 puntos para la siguiente función.
7. low, patch: continuación sin sangría francesa; viñeta separada, líneas alineadas.
8. medium, defer: configuración de control documental ausente ya era admisible en el catálogo. Mostrar raya explícita; completar datos institucionales requiere valores autorizados y no copiar personas del ejemplo.
9. low, patch: JPEG inválido consumido sin validación; validar disponibilidad/tipo/canales y error controlado.
10. medium, patch: pruebas de strings insuficientes; regresiones de color, delimitadores PDF, tamaños excesivos y caracteres, además lectura completa/geométrica con PDFPlumber e inspección visual de todas las páginas.
