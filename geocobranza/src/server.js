
// ==========================================
// 1. DEPENDENCIAS
// ==========================================

const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');
const jwt = require('jsonwebtoken');

// Middleware de autenticación
const verificarToken = require('./auth');


// ==========================================
// 2. CONFIGURACIÓN DE LA API
// ==========================================

const app = express();

app.use(cors());
app.use(express.json());

const RUTA_JSON = path.join(
    __dirname,
    'config/data/info.json'
);

const port = 3000;

const JWT_SECRET = 'geocobranza_clave_secreta_2026';


// ==========================================
// 3. FUNCIONES PARA MANEJAR EL JSON
// ==========================================

function leerDatos() {

    const contenido = fs.readFileSync(
        RUTA_JSON,
        'utf8'
    );

    return JSON.parse(contenido);
}

function guardarDatos(datos) {

    fs.writeFileSync(
        RUTA_JSON,
        JSON.stringify(datos, null, 2),
        'utf8'
    );

}


// ==========================================
// 4. RUTA PRINCIPAL
// ==========================================

app.get('/', (req, res) => {

    res.json({
        ok: true,
        mensaje: 'Bienvenido a la API de GeoCobranza'
    });

});


// ==========================================
// 5. CONSULTAR GESTORES
// ==========================================

app.get('/gestores', (req, res) => {

    try {

        const datos = leerDatos();

        const gestores = datos.gestores.map(gestor => ({
            id: gestor.id,
            nombres: gestor.nombres,
            usuario: gestor.usuario,
            agencia_id: gestor.agencia_id,
            estado: gestor.estado
        }));

        res.json({
            ok: true,
            total: gestores.length,
            gestores: gestores
        });

    } catch (error) {

        res.status(500).json({
            ok: false,
            mensaje: 'Error al consultar los gestores'
        });

    }

});


// ==========================================
// 6. INICIAR SESIÓN
// ==========================================

app.post('/api/login', (req, res) => {

    try {

        const { usuario, clave } = req.body;

        if (!usuario || !clave) {
            return res.status(400).json({
                ok: false,
                mensaje: 'Usuario y clave son obligatorios'
            });
        }

        const datos = leerDatos();

        const gestor = datos.gestores.find(g =>
            g.usuario === usuario &&
            g.clave === clave
        );

        if (!gestor) {
            return res.status(401).json({
                ok: false,
                mensaje: 'Usuario o clave incorrectos'
            });
        }

        if (gestor.estado !== 'ACTIVO') {
            return res.status(403).json({
                ok: false,
                mensaje: 'El gestor se encuentra inactivo'
            });
        }

        // Generar token JWT
        const token = jwt.sign(
            {
                id: gestor.id,
                agencia_id: gestor.agencia_id
            },
            JWT_SECRET,
            {
                expiresIn: '8h'
            }
        );

        res.json({
            ok: true,
            mensaje: 'Inicio de sesión exitoso',
            token: token,
            gestor: {
                id: gestor.id,
                nombres: gestor.nombres,
                usuario: gestor.usuario,
                agencia_id: gestor.agencia_id
            }
        });

    } catch (error) {

        res.status(500).json({
            ok: false,
            mensaje: 'Error al iniciar sesión'
        });

    }

});


// ==========================================
// 7. CONSULTAR PERFIL DEL GESTOR
// ==========================================

app.get('/api/perfil', verificarToken, (req, res) => {

    res.json({
        ok: true,
        mensaje: 'Token validado correctamente',
        gestor: req.gestor
    });

});


// ==========================================
// 8. CONSULTAR SOCIOS DEL GESTOR
// ==========================================

app.get('/api/socios', verificarToken, (req, res) => {

    try {

        const datos = leerDatos();

        const socios = datos.socios.filter(socio =>
            socio.gestor_id === req.gestor.id
        );

        res.json({
            ok: true,
            total: socios.length,
            gestor_id: req.gestor.id,
            socios: socios
        });

    } catch (error) {

        res.status(500).json({
            ok: false,
            mensaje: 'Error al consultar los socios'
        });

    }

});


// ==========================================
// 9. CONSULTAR SOCIOS EN MORA
// ==========================================

function consultarSociosMora(req, res) {

    try {

        const datos = leerDatos();

        const diasMinimos = req.query.diasMinimos === undefined
            ? 1
            : Number(req.query.diasMinimos);

        if (
            !Number.isInteger(diasMinimos) ||
            diasMinimos < 1
        ) {
            return res.status(400).json({
                ok: false,
                mensaje: 'diasMinimos debe ser un número entero mayor o igual a 1'
            });
        }

        const sociosEnMora = datos.socios.filter(socio =>

            socio.gestor_id === req.gestor.id &&

            socio.credito &&

            socio.credito.estado === 'VENCIDO' &&

            Number(socio.credito.dias_mora) >= diasMinimos

        );

        res.json({
            ok: true,
            gestor_id: req.gestor.id,
            dias_minimos: diasMinimos,
            total: sociosEnMora.length,
            socios: sociosEnMora
        });

    } catch (error) {

        res.status(500).json({
            ok: false,
            mensaje: 'Error al consultar socios en mora'
        });

    }

}

// Ambas direcciones consultan la misma información
app.get('/api/sociosd', verificarToken, consultarSociosMora);
app.get('/api/socios/mora', verificarToken, consultarSociosMora);


// ==========================================
// 10. CONSULTAR UN SOCIO POR SU ID
// ==========================================

app.get('/api/socios/:id', verificarToken, (req, res) => {

    try {

        const datos = leerDatos();

        const idSocio = req.params.id;

        const socio = datos.socios.find(s =>

            s.id === idSocio &&
            s.gestor_id === req.gestor.id

        );

        if (!socio) {

            return res.status(404).json({
                ok: false,
                mensaje: 'Socio no encontrado o no tienes permiso para consultarlo'
            });

        }

        res.json({
            ok: true,
            mensaje: 'Socio encontrado',
            socio: socio
        });

    } catch (error) {

        res.status(500).json({
            ok: false,
            mensaje: 'Error al consultar el socio'
        });

    }

});


// ==========================================
// 11. INICIAR SERVIDOR
// ==========================================

app.listen(port, () => {

    console.log('================================');
    console.log(' GEOCOBRANZA API');
    console.log('================================');
    console.log(`Servidor: http://localhost:${port}`);
    console.log('Estado: ACTIVO');
    console.log('================================');

});
