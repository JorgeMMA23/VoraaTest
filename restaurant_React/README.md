# Incident Manager

Sistema de gestión de incidencias con dashboard de métricas y chat por incidencia.
Construido con **React + TypeScript + Vite + Zustand**, siguiendo **Clean Architecture** y principios **SOLID**.

---

## 🚀 Inicio rápido

```bash
# 1. Instalar dependencias
npm install

# 2. Ajustar la URL del backend si fuera necesario en .env
#    VITE_API_BASE_URL=http://localhost:3000/api

# 3. Levantar el servidor de desarrollo
npm run dev

# 4. Compilar para producción
npm run build

# 5. Verificar tipos sin compilar
npm run type-check
```

El frontend espera un backend Node.js en `http://localhost:3000` (configurable por env).

---

## 🏗 Arquitectura

El proyecto separa el código en **cuatro capas** con dependencias unidireccionales:

```
┌────────────────────────────────────────────┐
│           presentation (React)             │  ← UI, stores, routing
│              │                              │
│              ▼                              │
│             domain                          │  ← entidades, interfaces, use cases
│              ▲                              │
│              │                              │
│              data                           │  ← repos, datasources, mappers, DTOs
│              │                              │
│              ▼                              │
│              core                           │  ← HTTP, config, errores, utils
└────────────────────────────────────────────┘
```

### `src/core/`
Infraestructura transversal: configuración (`env`, `endpoints`, `container`), cliente HTTP basado en `fetch` con timeout/abort, jerarquía de errores y utilidades.

### `src/domain/`
**Capa más interna y pura.** Solo TypeScript, sin dependencias externas:
- **entities/**: tipos puros del dominio (`Incident`, `ChatMessage`, `User`, `DashboardMetrics`).
- **repositories/**: contratos (interfaces) que el dominio exige.
- **usecases/**: una clase por operación, con su única responsabilidad. Reciben dependencias por constructor.

### `src/data/`
**Implementación de los contratos del dominio.**
- **dto/**: forma exacta del JSON del backend.
- **datasources/**: clases que hacen llamadas HTTP a endpoints.
- **mappers/**: convierten DTO → entidad de dominio.
- **repositories/**: implementan las interfaces de `domain`.

### `src/presentation/`
React + Zustand:
- **components/ui**: Button, Card, Modal, Input, Badge…
- **components/layout**: Sidebar, Topbar, AppShell.
- **components/charts**: KPIs y gráficos del dashboard (Recharts).
- **pages/**: una carpeta por feature.
- **stores/**: stores Zustand que orquestan los use cases.
- **routes/**: configuración de React Router.
- **styles/**: tokens CSS globales.

### Composition Root
`src/core/config/container.ts` es el único lugar donde se instancian implementaciones concretas y se cablean a sus dependencias. Cambiar de backend o usar mocks solo requiere editar este archivo.

---

## 🧱 Principios SOLID aplicados

| Principio | Cómo se aplica |
|-----------|----------------|
| **SRP** | Cada caso de uso (`CreateIncidentUseCase`, `SendMessageUseCase`, etc.) tiene una sola razón para cambiar. |
| **OCP** | Añadir un nuevo origen de datos no toca el dominio: basta con crear un repositorio nuevo que implemente la misma interfaz. |
| **LSP** | Cualquier implementación de `IIncidentRepository` puede sustituir a otra sin romper el dominio. |
| **ISP** | Interfaces pequeñas y específicas (`IChatRepository`, `IMetricsRepository`…) en vez de una "interface dios". |
| **DIP** | El dominio define los contratos; `data` los implementa. Los use cases dependen de abstracciones, no de `fetch` ni de Zustand. |

---

## 🌐 Contrato del backend (Node.js)

El frontend espera estos endpoints REST sirviendo JSON en `http://localhost:3000/api`.

### Incidencias

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET    | `/incidents`       | Lista todas las incidencias |
| GET    | `/incidents/:id`   | Detalle de una incidencia |
| POST   | `/incidents`       | Crear incidencia |
| PUT    | `/incidents/:id`   | Actualizar incidencia |
| DELETE | `/incidents/:id`   | Eliminar incidencia |

**Forma del JSON (IncidentDto):**
```json
{
  "id": "uuid",
  "title": "Caída del servicio de pagos",
  "description": "Los usuarios reportan timeouts...",
  "status": "open",          // open | in_progress | resolved | closed
  "priority": "high",        // low | medium | high | critical
  "assigneeId": "user-1",
  "reporterId": "user-2",
  "tags": ["backend", "urgente"],
  "createdAt": "2026-05-10T10:00:00.000Z",
  "updatedAt": "2026-05-10T10:00:00.000Z"
}
```

### Mensajes del chat (por incidencia)

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET    | `/incidents/:incidentId/messages`              | Listar mensajes |
| POST   | `/incidents/:incidentId/messages`              | Crear mensaje |
| PUT    | `/incidents/:incidentId/messages/:messageId`   | Editar mensaje |
| DELETE | `/incidents/:incidentId/messages/:messageId`   | Eliminar mensaje |

**Forma del JSON (ChatMessageDto):**
```json
{
  "id": "uuid",
  "incidentId": "uuid",
  "authorId": "user-1",
  "authorName": "María",
  "content": "Ya estoy revisando esto",
  "createdAt": "2026-05-10T10:05:00.000Z"
}
```

### Usuarios

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET    | `/users`     | Lista |
| GET    | `/users/:id` | Detalle |
| POST   | `/users`     | Crear |
| PUT    | `/users/:id` | Actualizar |
| DELETE | `/users/:id` | Eliminar |

```json
{
  "id": "uuid",
  "name": "María González",
  "email": "maria@empresa.com",
  "role": "admin",    // admin | agent | viewer
  "createdAt": "...",
  "updatedAt": "..."
}
```

### Métricas del dashboard

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET    | `/metrics/dashboard` | Agregados para el dashboard |

```json
{
  "totalIncidents": 124,
  "openIncidents": 18,
  "resolvedIncidents": 96,
  "avgResolutionHours": 6.4,
  "byStatus": [
    { "status": "open", "count": 18 },
    { "status": "in_progress", "count": 10 },
    { "status": "resolved", "count": 96 }
  ],
  "byPriority": [
    { "priority": "low", "count": 24 },
    { "priority": "medium", "count": 60 },
    { "priority": "high", "count": 32 },
    { "priority": "critical", "count": 8 }
  ],
  "trend": [
    { "date": "2026-05-04", "created": 6, "resolved": 5 },
    { "date": "2026-05-05", "created": 8, "resolved": 7 }
  ]
}
```

---

## 🧰 Stack

- **React 18** con hooks y `<StrictMode>`
- **TypeScript 5** en estricto
- **Vite 5** como bundler/dev server
- **Zustand 4** + middleware `devtools`
- **React Router 6**
- **Recharts** para visualizaciones
- **date-fns** para fechas (locale `es`)
- **lucide-react** para iconografía

---

## 🧪 Sustituir HTTP por mocks

Para tests o demos sin backend, basta con sustituir el `httpClient` o las implementaciones de repositorio en `src/core/config/container.ts`:

```ts
// Ejemplo: repo en memoria para incidencias
const incidentRepo = new InMemoryIncidentRepository();
```

Como los stores dependen solo de `container`, ningún componente cambia.

---

## 📁 Estructura completa

```
src/
├── core/
│   ├── config/        env.ts, endpoints.ts, container.ts
│   ├── errors/        AppError.ts
│   ├── http/          HttpClient.ts
│   ├── types/         common.ts
│   └── utils/         date.ts, cn.ts
├── data/
│   ├── datasources/   Incident/Chat/User/MetricsRemoteDataSource.ts
│   ├── dto/           dto.ts
│   ├── mappers/       *Mapper.ts
│   └── repositories/  *RepositoryImpl.ts
├── domain/
│   ├── entities/      Incident, ChatMessage, User, DashboardMetrics
│   ├── repositories/  I*Repository.ts
│   └── usecases/      incident, chat, user, metrics .usecases.ts
└── presentation/
    ├── components/    ui, layout, charts
    ├── hooks/
    ├── pages/         dashboard, incidents, users
    ├── routes/        AppRoutes.tsx
    ├── stores/        incident, chat, user, metrics, session .store.ts
    └── styles/        global.css
```
