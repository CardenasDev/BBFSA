import { chromium } from 'playwright-core';

const [, , outputPath] = process.argv;
const token = process.env.BBF_WORK_PDF_TOKEN;

if (!outputPath || !token) {
  throw new Error('Se requieren la ruta de salida y BBF_WORK_PDF_TOKEN.');
}

const browser = await chromium.launch({
  executablePath: 'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe',
  headless: true,
});

try {
  const page = await browser.newPage();
  await page.goto('http://127.0.0.1:4200/login', { waitUntil: 'networkidle' });
  await page.evaluate((accessToken) => {
    localStorage.setItem('access_token', accessToken);
    localStorage.setItem('auth_user', JSON.stringify({ id_usuario: 99, nombre_usuario: 'Prueba impresión obra' }));
    localStorage.setItem('roles', '[]');
    localStorage.setItem('permissions', JSON.stringify([
      { codigo: 'CONTRATACION_VER' },
      { codigo: 'CONTRATACION_HISTORIAL_VER' },
    ]));
  }, token);

  await page.goto('http://127.0.0.1:4200/admin/contracting/contracts/9/print', { waitUntil: 'networkidle' });
  try {
    await page.locator('.work-contract-page').nth(4).waitFor({ state: 'visible', timeout: 60_000 });
  } catch (error) {
    console.error(`URL final: ${page.url()}`);
    console.error(`Texto visible: ${(await page.locator('body').innerText()).slice(0, 2_000)}`);
    throw error;
  }

  const pageCount = await page.locator('.work-contract-page').count();
  if (pageCount !== 5) {
    throw new Error(`Se esperaban 5 páginas renderizadas y se encontraron ${pageCount}.`);
  }

  await page.pdf({
    path: outputPath,
    format: 'Letter',
    printBackground: true,
    preferCSSPageSize: true,
    margin: { top: '0', right: '0', bottom: '0', left: '0' },
  });
} finally {
  await browser.close();
}

console.log(`PDF generado: ${outputPath}`);
