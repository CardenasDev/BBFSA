import fs from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import * as pdfjsLib from 'pdfjs-dist/legacy/build/pdf.mjs';

const pdfPath = path.resolve('..', 'Back', 'storage', 'certificate-debug.pdf');
const outputPath = path.resolve('..', 'Back', 'storage', 'certificate-debug-render.png');
const bytes = fs.readFileSync(pdfPath);
const loadingTask = pdfjsLib.getDocument({ data: bytes, disableFontFace: true });
const document = await loadingTask.promise;
const page = await document.getPage(1);
const viewport = page.getViewport({ scale: 1 });
const canvas = document.createElement('canvas');
canvas.width = Math.ceil(viewport.width);
canvas.height = Math.ceil(viewport.height);
const context = canvas.getContext('2d');
await page.render({ canvasContext: context, viewport }).promise;
fs.writeFileSync(outputPath, Buffer.from(canvas.toDataURL('image/png').split(',')[1], 'base64'));
console.log(JSON.stringify({ pages: document.numPages, width: viewport.width, height: viewport.height, output: outputPath }));
