
const jwt = require('jsonwebtoken');

const JWT_SECRET = 'geocobranza_clave_secreta_2026';

function verificarToken(req, res, next) {

    // Obtener el encabezado Authorization
    const encabezado = req.headers.authorization;

    // Comprobar que exista el encabezado
    if (!encabezado) {
        return res.status(401).json({
            ok: false,
            mensaje: 'No se proporcionó un token'
        });
    }

    // Comprobar que tenga el formato Bearer
    const partes = encabezado.trim().split(/\s+/);

    if (
        partes.length !== 2 ||
        partes[0].toLowerCase() !== 'bearer' ||
        !partes[1]
    ) {
        return res.status(401).json({
            ok: false,
            mensaje: 'Formato de token incorrecto. Utiliza Bearer Token'
        });
    }

    const token = partes[1];

    try {

        // Validar el token
        const decoded = jwt.verify(token, JWT_SECRET);

        // Guardar los datos del gestor autenticado
        req.gestor = decoded;

        // Continuar con la ruta solicitada
        next();

    } catch (error) {

        return res.status(401).json({
            ok: false,
            mensaje: 'Token inválido o expirado'
        });

    }
}

module.exports = verificarToken;
