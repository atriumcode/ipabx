import { NestFactory } from "@nestjs/core"
import { ValidationPipe } from "@nestjs/common"
import { AppModule } from "./app.module"

async function bootstrap() {
  const app = await NestFactory.create(AppModule)

  // Habilitar CORS para comunicação com frontend
  app.enableCors({
    origin: process.env.FRONTEND_URL || "http://localhost:3000",
    credentials: true,
  })

  // Prefixo global para API
  app.setGlobalPrefix("api")

  // Validação automática de DTOs
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  )

  const porta = process.env.PORT || 3001
  await app.listen(porta)
  console.log(`[PBX Moderno] Backend iniciado na porta ${porta}`)
}

bootstrap()
