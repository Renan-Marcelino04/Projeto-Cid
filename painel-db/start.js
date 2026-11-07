import app from './server.js';

const port = Number(process.env.PORT || 3000);
app.listen(port, '127.0.0.1', () => console.log(`CK Autoshop: http://localhost:${port}`));
