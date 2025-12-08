import { Entity, Column, ManyToOne, JoinColumn } from "typeorm"
import { BaseEntity } from "../../../common/entities/base.entity"
import { Tenant } from "../../tenants/entities/tenant.entity"

/**
 * Entidade de Ramal (Extension)
 */
@Entity("extensions")
export class Extension extends BaseEntity {
  @Column({ name: "tenant_id" })
  tenantId: number

  @ManyToOne(() => Tenant)
  @JoinColumn({ name: "tenant_id" })
  tenant: Tenant

  @Column({ length: 50 })
  numero: string

  @Column({ length: 255 })
  nome: string

  @Column({ length: 255 })
  senha: string

  @Column({ name: "caller_id", length: 255, nullable: true })
  callerId: string

  @Column({ length: 20, default: "pjsip" })
  tipo: "pjsip" | "sip"

  @Column({ length: 100, default: "from-internal" })
  context: string

  @Column({ length: 50, nullable: true })
  mailbox: string

  @Column({ length: 255, default: "alaw,ulaw,g729" })
  codecs: string

  @Column({ length: 50, default: "udp" })
  transporte: string

  @Column({ length: 50, default: "yes" })
  nat: string

  @Column({ name: "dtmf_mode", length: 50, default: "rfc4733" })
  dtmfMode: string

  @Column({ name: "max_contacts", default: 1 })
  maxContacts: number

  @Column({ name: "qualifyfreq", default: 60 })
  qualifyfreq: number

  @Column({ default: true })
  ativo: boolean

  @Column({ default: false })
  online: boolean

  @Column({ name: "ultimo_registro", nullable: true })
  ultimoRegistro: Date

  @Column({ type: "jsonb", default: {} })
  configuracoes: Record<string, any>
}
