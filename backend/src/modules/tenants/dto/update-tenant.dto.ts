import { IsString, IsOptional, IsEnum, IsInt, Min, IsBoolean } from "class-validator"

export class UpdateTenantDto {
  @IsString({ message: "Nome deve ser uma string" })
  @IsOptional()
  nome?: string

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

  @IsBoolean({ message: "Ativo deve ser verdadeiro ou falso" })
  @IsOptional()
  ativo?: boolean
}
