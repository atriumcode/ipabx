import { IsString, IsNotEmpty, IsOptional, IsEnum, IsInt, Min } from "class-validator"

export class CreateTenantDto {
  @IsString({ message: "Nome deve ser uma string" })
  @IsNotEmpty({ message: "Nome é obrigatório" })
  nome: string

  @IsString({ message: "Domínio deve ser uma string" })
  @IsOptional()
  dominio?: string

  @IsEnum(["basico", "profissional", "enterprise", "ilimitado"], { message: "Plano inválido" })
  @IsOptional()
  plano?: "basico" | "profissional" | "enterprise" | "ilimitado"

  @IsInt({ message: "Máximo de ramais deve ser um número inteiro" })
  @Min(1, { message: "Deve ter no mínimo 1 ramal" })
  @IsOptional()
  maxRamais?: number

  @IsInt({ message: "Máximo de troncos deve ser um número inteiro" })
  @Min(1, { message: "Deve ter no mínimo 1 tronco" })
  @IsOptional()
  maxTroncos?: number
}
