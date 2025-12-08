import { Card, CardHeader, CardTitle, CardContent } from "../components/ui/Card"
import Button from "../components/ui/Button"
import { Plus } from "lucide-react"

export default function Queues() {
  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Filas</h1>
          <p className="text-muted-foreground">Gerenciamento de filas de atendimento</p>
        </div>
        <Button>
          <Plus className="w-4 h-4 mr-2" />
          Nova Fila
        </Button>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Lista de Filas</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="text-center py-8 text-muted-foreground">Nenhuma fila cadastrada</div>
        </CardContent>
      </Card>
    </div>
  )
}
