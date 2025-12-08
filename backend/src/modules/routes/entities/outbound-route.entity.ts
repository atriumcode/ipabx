import { Entity, Column, ManyToOne, JoinColumn } from "typeorm"
import { BaseEntity } from "../../../common/entities/base.entity"
import { Tenant } from "../../tenants/entities/tenant.entity"

@Entity("rotas_saida")
export class OutboundRoute extends BaseEntity {
  @Column({ name: "tenant_id" })
  tenantId: number

  @Column()
  nome: string

  @Column({ nullable: true })
  descricao: string

  @Column({ name: "padrao_discagem" })
  padraoDiscagem: string

  @Column({ name: "tronco_id" })
  troncoId: number

  @Column({ name: "prefixo_adicionar", nullable: true })
  prefixoAdicionar: string

  @Column({ name: "digitos_remover", default: 0 })
  digitosRemover: number

  @Column({ type: "integer", default: 0 })
  prioridade: number

  @Column({ default: true })
  ativo: boolean

  @ManyToOne(() => Tenant)
  @JoinColumn({ name: "tenant_id" })
  tenant: Tenant
}
