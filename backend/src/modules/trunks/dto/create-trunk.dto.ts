import { IsString, IsNotEmpty, IsOptional, IsEnum, IsInt, IsBoolean, Min, Max } from "class-validator"

export class CreateTrunkDto {
  @IsString({ message: "Nome deve ser uma string" })
  @IsNotEmpty({ message: "Nome é obrigatório" })
  nome: string

  @IsEnum(["pjsip", "sip"], { message: "Tipo deve ser pjsip ou sip" })
  @IsOptional()
  tipo?: "pjsip" | "sip"

  @IsString({ message: "Host deve ser uma string" })
  @IsNotEmpty({ message: "Host é obrigatório" })
  host: string

  @IsInt({ message: "Porta deve ser um número inteiro" })
  @Min(1, { message: "Porta deve ser maior que 0" })
  @Max(65535, { message: "Porta deve ser menor que 65536" })
  @IsOptional()
  porta?: number

  @IsString({ message: "Usuário deve ser uma string" })
  @IsOptional()
  usuario?: string

  @IsString({ message: "Senha deve ser uma string" })
  @IsOptional()
  senha?: string

  @IsBoolean({ message: "Registrar deve ser verdadeiro ou falso" })
  @IsOptional()
  registrar?: boolean

  @IsString({ message: "Transporte deve ser uma string" })
  @IsOptional()
  transporte?: string

  @IsString({ message: "Codecs deve ser uma string" })
  @IsOptional()
  codecs?: string
}
