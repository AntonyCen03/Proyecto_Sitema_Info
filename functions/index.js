const functions = require('firebase-functions');
const admin = require('firebase-admin');

try {
  admin.initializeApp();
} catch (e) {
  // already initialized in emulator
}

const path = require('path');

exports.uploadProfilePhoto = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Debe iniciar sesión para subir la foto.'
    );
  }

  const uid = context.auth.uid;
  const base64 = (data && data.base64) ? String(data.base64) : '';
  let contentType = (data && data.contentType) ? String(data.contentType) : 'image/jpeg';

  // Validar input
  if (!base64) {
    throw new functions.https.HttpsError('invalid-argument', 'Falta imagen en base64');
  }
  const allowed = new Set(['image/jpeg', 'image/png', 'image/webp', 'image/gif']);
  if (!allowed.has(contentType)) {
    contentType = 'image/jpeg';
  }

  // Decodificar base64 (admite prefijo dataURL)
  let b64 = base64;
  const comma = base64.indexOf(',');
  if (comma >= 0) {
    b64 = base64.substring(comma + 1);
  }
  let buffer;
  try {
    buffer = Buffer.from(b64, 'base64');
  } catch (e) {
    throw new functions.https.HttpsError('invalid-argument', 'Base64 inválido');
  }

  // Límite razonable (5 MB)
  const maxBytes = 5 * 1024 * 1024;
  if (buffer.length > maxBytes) {
    throw new functions.https.HttpsError('resource-exhausted', 'La imagen supera 5MB');
  }

  // Extensión por contentType
  const ext = contentType === 'image/png'
    ? 'png'
    : contentType === 'image/webp'
      ? 'webp'
      : contentType === 'image/gif'
        ? 'gif'
        : 'jpg';

  const ts = Date.now();
  const filePath = path.posix.join('user_photos', uid, `${ts}.${ext}`);

  const bucket = admin.storage().bucket();
  const file = bucket.file(filePath);

  await file.save(buffer, {
    contentType,
    metadata: {
      cacheControl: 'public, max-age=3600'
    }
  });

  // Generar URL firmada por 1 año
  const expires = Date.now() + 365 * 24 * 60 * 60 * 1000;
  const [signedUrl] = await file.getSignedUrl({
    action: 'read',
    expires
  });

  return {
    url: signedUrl,
    path: filePath,
    contentType,
    size: buffer.length
  };
});
