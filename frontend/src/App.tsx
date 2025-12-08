import { Routes, Route, Navigate } from "react-router-dom"
import { useAuthStore } from "./stores/authStore"
import LoginPage from "./pages/LoginPage"
import DashboardLayout from "./layouts/DashboardLayout"
import Dashboard from "./pages/Dashboard"
import Extensions from "./pages/Extensions"
import Trunks from "./pages/Trunks"
import Queues from "./pages/Queues"
import Groups from "./pages/Groups"
import Ivr from "./pages/Ivr"
import RoutesPageComponent from "./pages/Routes"
import Cdr from "./pages/Cdr"
import Recordings from "./pages/Recordings"
import Users from "./pages/Users"
import Settings from "./pages/Settings"

function App() {
  const { isAuthenticated } = useAuthStore()

  return (
    <Routes>
      <Route path="/login" element={!isAuthenticated ? <LoginPage /> : <Navigate to="/" />} />

      <Route path="/" element={isAuthenticated ? <DashboardLayout /> : <Navigate to="/login" />}>
        <Route index element={<Dashboard />} />
        <Route path="ramais" element={<Extensions />} />
        <Route path="troncos" element={<Trunks />} />
        <Route path="filas" element={<Queues />} />
        <Route path="grupos" element={<Groups />} />
        <Route path="ura" element={<Ivr />} />
        <Route path="rotas" element={<RoutesPageComponent />} />
        <Route path="cdr" element={<Cdr />} />
        <Route path="gravacoes" element={<Recordings />} />
        <Route path="usuarios" element={<Users />} />
        <Route path="configuracoes" element={<Settings />} />
      </Route>
    </Routes>
  )
}

export default App
