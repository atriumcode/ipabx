import { Entity, Column, ManyToOne, JoinColumn } from "typeorm"
import { BaseEntity } from "../../../common/entities/base.entity"
import { Tenant } from "../../tenants/entities/tenant.entity"

/**
 * Entidade de Usuário do Sistema
 */
@Entity("system_users")
export class SystemUser extends BaseEntity {
  @Column({ type: "uuid", generated: "uuid", unique: true })
  uuid: string

  @Column({ name: "tenant_id" })
  tenantId: number

  @ManyToOne(() => Tenant)
  @JoinColumn({ name: "tenant_id" })
  tenant: Tenant

  @Column({ length: 255 })
  nome: string

  @Column({ length: 255, unique: true })
  email: string

  @Column({ length: 255, select: false })
  senha: string

  @Column({ length: 50, default: "operador" })
  perfil: "root" | "admin" | "operador" | "leitura"

  @Column({ default: true })
  ativo: boolean

  @Column({ name: "ultimo_login", nullable: true })
  ultimoLogin: Date

  @Column({ type: "jsonb", default: {} })
  permissoes: Record<string, any>
}
