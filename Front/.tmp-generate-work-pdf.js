const fs = require('node:fs');
const { chromium } = require('playwright');

(async () => {
  const token = fs.readFileSync('D:/Repo/BBf/BBFSA/.tmp-pdf-review/jwt-token.txt', 'utf8').trim();
  if (!token) throw new Error('BBF_TOKEN missing');

  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();

  await page.goto('http://127.0.0.1:4200/login', { waitUntil: 'networkidle' });
  await page.evaluate((tk) => {
    localStorage.setItem('access_token', tk);
    localStorage.setItem('auth_user', JSON.stringify({ id_usuario: 99, nombre_usuario: 'Prueba impresi�n obra' }));
    localStorage.setItem('roles', '[]');
    localStorage.setItem('permissions', JSON.stringify([{ codigo: 'CONTRATACION_VER' }, { codigo: 'CONTRATACION_HISTORIAL_VER' }]));
  }, token);

  await page.goto('http://127.0.0.1:4200/admin/contracting/contracts/9/print', { waitUntil: 'networkidle' });

  await page.pdf({
    path: 'D:/Repo/BBf/BBFSA/.tmp-pdf-review/BBTH-F-014-dev-generated.pdf',
    format: 'Letter',
    printBackground: true,
    preferCSSPageSize: true,
    margin: { top: '0', right: '0', bottom: '0', left: '0' }
  });

  console.log('PDF_OK');
  await browser.close();
})();