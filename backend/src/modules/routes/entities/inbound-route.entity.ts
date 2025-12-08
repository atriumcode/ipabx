import { Entity, Column, ManyToOne, JoinColumn } from "typeorm"
import { BaseEntity } from "../../../common/entities/base.entity"
import { Tenant } from "../../tenants/entities/tenant.entity"

@Entity("rotas_entrada")
export class InboundRoute extends BaseEntity {
  @Column({ name: "tenant_id" })
  tenantId: number

  @Column()
  nome: string

  @Column({ nullable: true })
  descricao: string

  @Column({ name: "padrao_did" })
  padraoDid: string

  @Column({ name: "tipo_destino" })
  tipoDestino: string

  @Column({ name: "destino_id", nullable: true })
  destinoId: number

  @Column({ type: "integer", default: 0 })
  prioridade: number

  @Column({ default: true })
  ativo: boolean

  @ManyToOne(() => Tenant)
  @JoinColumn({ name: "tenant_id" })
  tenant: Tenant
}
