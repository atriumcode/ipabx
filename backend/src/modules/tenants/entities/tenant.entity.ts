import { Entity, Column } from "typeorm"
import { BaseEntity } from "../../../common/entities/base.entity"

/**
 * Entidade Tenant (Inquilino/Empresa)
 * Representa uma empresa no sistema multitenant
 */
@Entity("tenants")
export class Tenant extends BaseEntity {
  @Column({ type: "uuid", generated: "uuid", unique: true })
  uuid: string

  @Column({ length: 255 })
  nome: string

  @Column({ length: 255, unique: true, nullable: true })
  dominio: string

  @Column({ default: true })
  ativo: boolean

  @Column({ length: 50, default: "basico" })
  plano: "basico" | "profissional" | "enterprise" | "ilimitado"

  @Column({ name: "max_ramais", default: 10 })
  maxRamais: number

  @Column({ name: "max_troncos", default: 2 })
  maxTroncos: number

  @Column({ type: "jsonb", default: {} })
  configuracoes: Record<string, any>
}
