import { Entity, Column, ManyToOne, JoinColumn } from "typeorm"
import { BaseEntity } from "../../../common/entities/base.entity"
import { Tenant } from "../../tenants/entities/tenant.entity"

/**
 * Entidade de Tronco SIP/PJSIP
 */
@Entity("trunks")
export class Trunk extends BaseEntity {
  @Column({ name: "tenant_id" })
  tenantId: number

  @ManyToOne(() => Tenant)
  @JoinColumn({ name: "tenant_id" })
  tenant: Tenant

  @Column({ length: 255 })
  nome: string

  @Column({ length: 20, default: "pjsip" })
  tipo: "pjsip" | "sip"

  @Column({ length: 255 })
  host: string

  @Column({ default: 5060 })
  porta: number

  @Column({ length: 255, nullable: true })
  usuario: string

  @Column({ length: 255, nullable: true })
  senha: string

  @Column({ default: true })
  registrar: boolean

  @Column({ length: 100, default: "from-trunk" })
  context: string

  @Column({ length: 50, default: "udp" })
  transporte: string

  @Column({ length: 255, default: "alaw,ulaw,g729" })
  codecs: string

  @Column({ name: "dtmf_mode", length: 50, default: "rfc4733" })
  dtmfMode: string

  @Column({ length: 50, default: "yes" })
  sendrpid: string

  @Column({ length: 255, nullable: true })
  fromdomain: string

  @Column({ length: 255, nullable: true })
  fromuser: string

  @Column({ default: true })
  ativo: boolean

  @Column({ default: false })
  online: boolean

  @Column({ type: "jsonb", default: {} })
  configuracoes: Record<string, any>
}
