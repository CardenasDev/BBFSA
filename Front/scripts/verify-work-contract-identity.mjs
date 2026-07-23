import fs from 'node:fs';
import { unzipSync } from 'fflate';
import { getDocument } from 'pdfjs-dist/legacy/build/pdf.mjs';

const [, , docxPath, pdfPath] = process.argv;

if (!docxPath || !pdfPath) {
  throw new Error('Uso: node scripts/verify-work-contract-identity.mjs <original.docx> <generado.pdf>');
}

function decodeXml(value) {
  return value
    .replace(/&#(\d+);/g, (_, code) => String.fromCodePoint(Number(code)))
    .replace(/&#x([0-9a-f]+);/gi, (_, code) => String.fromCodePoint(Number.parseInt(code, 16)))
    .replace(/&amp;/g, '&')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&quot;/g, '"')
    .replace(/&apos;/g, "'");
}

function extractDocxBody(path) {
  const archive = unzipSync(new Uint8Array(fs.readFileSync(path)));
  const documentXml = new TextDecoder().decode(archive['word/document.xml']);
  const paragraphs = [...documentXml.matchAll(/<w:p(?:\s[^>]*)?>([\s\S]*?)<\/w:p>/g)];
  let listItem = 0;

  const texts = paragraphs.map(([, paragraphXml]) => {
    const text = [...paragraphXml.matchAll(/<w:t(?:\s[^>]*)?>([\s\S]*?)<\/w:t>/g)]
      .map((match) => decodeXml(match[1]))
      .join('');

    if (/<w:numPr>/.test(paragraphXml) && text.trim()) {
      listItem += 1;
      return `${listItem}. ${text}`;
    }

    return text;
  });

  const start = texts.findIndex((text) => text.startsWith('PRIMERO: el empleador contrata los servicios.'));
  const end = texts.findIndex((text, index) => index >= start && text.startsWith('DECIMO SEGUNDA.'));
  if (start < 0 || end < start) {
    throw new Error('No se encontraron los límites PRIMERO/DECIMO SEGUNDA en el DOCX.');
  }

  return texts.slice(start, end + 1).join(' ');
}

async function extractPdfBody(path) {
  const pdf = await getDocument({ data: new Uint8Array(fs.readFileSync(path)) }).promise;
  const lines = [];

  for (let pageNumber = 1; pageNumber <= pdf.numPages; pageNumber += 1) {
    const page = await pdf.getPage(pageNumber);
    const content = await page.getTextContent();
    const bodyItems = content.items
      .filter((item) => {
        const y = item.transform[5];
        return y > 92 && y < 650;
      })
      .sort((left, right) => {
        const yDifference = right.transform[5] - left.transform[5];
        return Math.abs(yDifference) > 2 ? yDifference : left.transform[4] - right.transform[4];
      });

    let previousY;
    let line = '';
    for (const item of bodyItems) {
      const y = Math.round(item.transform[5]);
      if (previousY !== undefined && Math.abs(y - previousY) > 2) {
        if (line.trim()) lines.push(line.trim());
        line = '';
      }
      line += item.str;
      previousY = y;
    }
    if (line.trim()) lines.push(line.trim());
  }

  const text = lines.join(' ');
  const start = text.indexOf('PRIMERO: el empleador contrata los servicios.');
  const finalText = 'última dirección registrada en la hoja de vida.';
  const end = text.indexOf(finalText, start);
  if (start < 0 || end < start) {
    throw new Error('No se encontraron los límites PRIMERO/DECIMO SEGUNDA en el PDF.');
  }

  return text.slice(start, end + finalText.length);
}

function normalizePagination(value) {
  return value
    .replace(/_+\s+Días/g, '{{PRORROGA_DIAS}} Días')
    .replace(/\b\d+\s+Días/g, '{{PRORROGA_DIAS}} Días')
    .replace(/\s+/g, ' ')
    .trim();
}

function mismatchMessage(expected, actual) {
  const limit = Math.min(expected.length, actual.length);
  let index = 0;
  while (index < limit && expected[index] === actual[index]) index += 1;
  const from = Math.max(0, index - 80);
  const to = index + 120;

  return [
    `Diferencia literal en el carácter ${index}.`,
    `DOCX: ${JSON.stringify(expected.slice(from, to))}`,
    `PDF:  ${JSON.stringify(actual.slice(from, to))}`,
  ].join('\n');
}

const expected = normalizePagination(extractDocxBody(docxPath));
const actual = normalizePagination(await extractPdfBody(pdfPath));

if (expected !== actual) {
  throw new Error(mismatchMessage(expected, actual));
}

for (const forbidden of [
  'Funciones dt',
  'A no prestar directa ni indirectamente',
  'Los servicios se prestarán',
]) {
  if (actual.includes(forbidden)) {
    throw new Error(`El PDF contiene texto prohibido: ${forbidden}`);
  }
}

console.log(`PASS: identidad literal DOCX/PDF (${actual.length} caracteres contractuales).`);
