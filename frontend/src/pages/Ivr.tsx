import { Card, CardHeader, CardTitle, CardContent } from "../components/ui/Card"

export default function Ivr() {
  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-bold">URA (IVR)</h1>
      <Card>
        <CardHeader>
          <CardTitle>Unidades de Resposta Audível</CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-muted-foreground">Funcionalidade em desenvolvimento</p>
        </CardContent>
      </Card>
    </div>
  )
}
