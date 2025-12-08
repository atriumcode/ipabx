import { IsString, IsNotEmpty, IsOptional, IsEnum, IsInt, Min } from "class-validator"

export class CreateQueueDto {
  @IsString({ message: "Nome deve ser uma string" })
  @IsNotEmpty({ message: "Nome é obrigatório" })
  nome: string

  @IsString({ message: "Número deve ser uma string" })
  @IsNotEmpty({ message: "Número é obrigatório" })
  numero: string

  @IsEnum(["ringall", "leastrecent", "fewestcalls", "random", "rrmemory", "linear"], {
    message: "Estratégia inválida",
  })
  @IsOptional()
  estrategia?: "ringall" | "leastrecent" | "fewestcalls" | "random" | "rrmemory" | "linear"

  @IsInt({ message: "Timeout deve ser um número inteiro" })
  @Min(1, { message: "Timeout deve ser maior que 0" })
  @IsOptional()
  timeout?: number

  @IsInt({ message: "Retry deve ser um número inteiro" })
  @Min(1, { message: "Retry deve ser maior que 0" })
  @IsOptional()
  retry?: number

  @IsInt({ message: "Wrapuptime deve ser um número inteiro" })
  @Min(0, { message: "Wrapuptime deve ser maior ou igual a 0" })
  @IsOptional()
  wrapuptime?: number

  @IsString({ message: "Música em espera deve ser uma string" })
  @IsOptional()
  musiconhold?: string
}
