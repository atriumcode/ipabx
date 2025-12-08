"use client"

import { useEffect, useState } from "react"
import { Plus, Circle } from "lucide-react"
import { Card, CardHeader, CardTitle, CardContent } from "../components/ui/Card"
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from "../components/ui/Table"
import Button from "../components/ui/Button"
import api from "../lib/api"

interface Trunk {
  id: number
  nome: string
  host: string
  tipo: string
  online: boolean
  ativo: boolean
}

export default function Trunks() {
  const [trunks, setTrunks] = useState<Trunk[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchTrunks()
  }, [])

  const fetchTrunks = async () => {
    try {
      const response = await api.get("/trunks")
      setTrunks(response.data)
    } catch (error) {
      console.error("Erro ao buscar troncos:", error)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Troncos</h1>
          <p className="text-muted-foreground">Gerenciamento de troncos SIP/PJSIP</p>
        </div>
        <Button>
          <Plus className="w-4 h-4 mr-2" />
          Novo Tronco
        </Button>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Lista de Troncos</CardTitle>
        </CardHeader>
        <CardContent>
          {loading ? (
            <div className="text-center py-8">Carregando...</div>
          ) : trunks.length === 0 ? (
            <div className="text-center py-8 text-muted-foreground">Nenhum tronco cadastrado</div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Status</TableHead>
                  <TableHead>Nome</TableHead>
                  <TableHead>Host</TableHead>
                  <TableHead>Tipo</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {trunks.map((trunk) => (
                  <TableRow key={trunk.id}>
                    <TableCell>
                      <Circle
                        className={`w-3 h-3 ${trunk.online ? "fill-green-500 text-green-500" : "fill-gray-400 text-gray-400"}`}
                      />
                    </TableCell>
                    <TableCell className="font-medium">{trunk.nome}</TableCell>
                    <TableCell>{trunk.host}</TableCell>
                    <TableCell>
                      <span className="px-2 py-1 text-xs rounded-full bg-primary/10 text-primary">
                        {trunk.tipo.toUpperCase()}
                      </span>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>
    </div>
  )
}
