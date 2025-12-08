import { Card, CardHeader, CardTitle, CardContent } from "../components/ui/Card"

export default function Cdr() {
  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-bold">CDR - Registros de Chamadas</h1>
      <Card>
        <CardHeader>
          <CardTitle>Histórico de Chamadas</CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-muted-foreground">Funcionalidade em desenvolvimento</p>
        </CardContent>
      </Card>
    </div>
  )
}
