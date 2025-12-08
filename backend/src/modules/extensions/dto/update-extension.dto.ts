import { IsString, IsOptional, IsEnum, IsBoolean, MinLength } from "class-validator"

export class UpdateExtensionDto {
  @IsString({ message: "Nome deve ser uma string" })
  @IsOptional()
  nome?: string

  @IsString({ message: "Senha deve ser uma string" })
  @MinLength(6, { message: "Senha deve ter no mínimo 6 caracteres" })
  @IsOptional()
  senha?: string

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

  @IsBoolean({ message: "Ativo deve ser verdadeiro ou falso" })
  @IsOptional()
  ativo?: boolean
}
