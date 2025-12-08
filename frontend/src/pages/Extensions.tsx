"use client"

import { useEffect, useState } from "react"
import { Plus, Edit, Trash2, Circle } from "lucide-react"
import { Card, CardHeader, CardTitle, CardContent } from "../components/ui/Card"
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from "../components/ui/Table"
import Button from "../components/ui/Button"
import api from "../lib/api"

interface Extension {
  id: number
  numero: string
  nome: string
  tipo: string
  online: boolean
  ativo: boolean
}

export default function Extensions() {
  const [extensions, setExtensions] = useState<Extension[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchExtensions()
  }, [])

  const fetchExtensions = async () => {
    try {
      const response = await api.get("/extensions")
      setExtensions(response.data)
    } catch (error) {
      console.error("Erro ao buscar ramais:", error)
    } finally {
      setLoading(false)
    }
  }

  const handleDelete = async (id: number) => {
    if (!confirm("Deseja realmente excluir este ramal?")) return

    try {
      await api.delete(`/extensions/${id}`)
      fetchExtensions()
    } catch (error) {
      console.error("Erro ao excluir ramal:", error)
      alert("Erro ao excluir ramal")
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Ramais</h1>
          <p className="text-muted-foreground">Gerenciamento de ramais SIP/PJSIP</p>
        </div>
        <Button>
          <Plus className="w-4 h-4 mr-2" />
          Novo Ramal
        </Button>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Lista de Ramais</CardTitle>
        </CardHeader>
        <CardContent>
          {loading ? (
            <div className="text-center py-8">Carregando...</div>
          ) : extensions.length === 0 ? (
            <div className="text-center py-8 text-muted-foreground">Nenhum ramal cadastrado</div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Status</TableHead>
                  <TableHead>Número</TableHead>
                  <TableHead>Nome</TableHead>
                  <TableHead>Tipo</TableHead>
                  <TableHead>Ações</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {extensions.map((ext) => (
                  <TableRow key={ext.id}>
                    <TableCell>
                      <Circle
                        className={`w-3 h-3 ${ext.online ? "fill-green-500 text-green-500" : "fill-gray-400 text-gray-400"}`}
                      />
                    </TableCell>
                    <TableCell className="font-medium">{ext.numero}</TableCell>
                    <TableCell>{ext.nome}</TableCell>
                    <TableCell>
                      <span className="px-2 py-1 text-xs rounded-full bg-primary/10 text-primary">
                        {ext.tipo.toUpperCase()}
                      </span>
                    </TableCell>
                    <TableCell>
                      <div className="flex gap-2">
                        <Button size="sm" variant="ghost">
                          <Edit className="w-4 h-4" />
                        </Button>
                        <Button size="sm" variant="ghost" onClick={() => handleDelete(ext.id)}>
                          <Trash2 className="w-4 h-4" />
                        </Button>
                      </div>
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
