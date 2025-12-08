import { IsString, IsNotEmpty, IsOptional, IsEnum, MinLength } from "class-validator"

export class CreateExtensionDto {
  @IsString({ message: "Número deve ser uma string" })
  @IsNotEmpty({ message: "Número é obrigatório" })
  numero: string

  @IsString({ message: "Nome deve ser uma string" })
  @IsNotEmpty({ message: "Nome é obrigatório" })
  nome: string

  @IsString({ message: "Senha deve ser uma string" })
  @IsNotEmpty({ message: "Senha é obrigatória" })
  @MinLength(6, { message: "Senha deve ter no mínimo 6 caracteres" })
  senha: string

  @IsString({ message: "Caller ID deve ser uma string" })
  @IsOptional()
  callerId?: string

  @IsEnum(["pjsip", "sip"], { message: "Tipo deve ser pjsip ou sip" })
  @IsOptional()
  tipo?: "pjsip" | "sip"

  @IsString({ message: "Codecs deve ser uma string" })
  @IsOptional()
  codecs?: string

  @IsString({ message: "Transporte deve ser uma string" })
  @IsOptional()
  transporte?: string
}
