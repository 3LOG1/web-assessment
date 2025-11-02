const http = require('http');
const PORT = process.env.PORT || 3000;
const MESSAGE = process.env.APP_MESSAGE || '';


const server = http.createServer((req, res) => {
if (req.method === 'GET' && req.url === '/version') {
const payload = JSON.stringify({ message: MESSAGE });
res.writeHead(200, { 'Content-Type': 'application/json' });
return res.end(payload);
}


res.writeHead(404, { 'Content-Type': 'application/json' });
res.end(JSON.stringify({ error: 'not found' }));
});


server.listen(PORT, () => {
console.log(`tiny-version-app listening on port ${PORT}`);
});
