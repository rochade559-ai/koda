const { Storage } = require('@google-cloud/storage');

const storage = new Storage();
const bucketName = 'koda-ebd27.firebasestorage.app';

async function setCors() {
  try {
    const bucket = storage.bucket(bucketName);

    await bucket.setMetadata({
      cors: [
        {
          origin: [
            "http://localhost:8080",
            "http://localhost:8081",
            "https://koda-ebd27.web.app",
            "https://koda-ebd27.firebaseapp.com",
            "https://www.kodaff.com",
            "https://kodaff.com",
            "https://admin.kodaff.com",
            "https://kodaff-admin.web.app"
          ],
          method: ["GET", "POST", "PUT", "DELETE", "HEAD", "OPTIONS"],
          maxAgeSeconds: 3600,
          responseHeader: [
            "Content-Type",
            "Authorization",
            "Content-Length",
            "User-Agent",
            "x-goog-resumable",
            "x-firebase-storage-version"
          ]
        }
      ]
    });

    console.log('✅ CORS configurado com sucesso!');

    const [metadata] = await bucket.getMetadata();
    console.log('\n📋 CORS atual:');
    console.log(JSON.stringify(metadata.cors, null, 2));
  } catch (err) {
    console.error('❌ Erro:', err.message);
  }
}

setCors();