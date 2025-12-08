import { Card, CardHeader, CardTitle, CardContent } from "../components/ui/Card"

export default function Recordings() {
  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-bold">Gravações</h1>
      <Card>
        <CardHeader>
          <CardTitle>Gerenciamento de Gravações</CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-muted-foreground">Funcionalidade em desenvolvimento</p>
        </CardContent>
      </Card>
    </div>
  )
}
