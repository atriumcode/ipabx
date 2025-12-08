import { IsEmail, IsString, MinLength, IsEnum, IsOptional, IsBoolean } from "class-validator"

export class UpdateUserDto {
  @IsString({ message: "Nome deve ser uma string" })
  @IsOptional()
  nome?: string

  @IsEmail({}, { message: "Email inválido" })
  @IsOptional()
  email?: string

  @IsString({ message: "Senha deve ser uma string" })
  @MinLength(6, { message: "Senha deve ter no mínimo 6 caracteres" })
  @IsOptional()
  senha?: string

  @IsEnum(["root", "admin", "operador", "leitura"], { message: "Perfil inválido" })
  @IsOptional()
  perfil?: "root" | "admin" | "operador" | "leitura"

  @IsBoolean({ message: "Ativo deve ser verdadeiro ou falso" })
  @IsOptional()
  ativo?: boolean
}
