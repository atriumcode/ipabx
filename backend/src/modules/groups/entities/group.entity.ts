import { Entity, Column, ManyToOne, JoinColumn, ManyToMany, JoinTable } from "typeorm"
import { BaseEntity } from "../../../common/entities/base.entity"
import { Tenant } from "../../tenants/entities/tenant.entity"
import { Extension } from "../../extensions/entities/extension.entity"

@Entity("grupos")
export class Group extends BaseEntity {
  @Column({ name: "tenant_id" })
  tenantId: number

  @Column()
  nome: string

  @Column({ nullable: true })
  descricao: string

  @Column({ name: "estrategia_toque", default: "ringall" })
  estrategiaToque: string

  @Column({ name: "tempo_toque", default: 30 })
  tempoToque: number

  @Column({ default: true })
  ativo: boolean

  @ManyToOne(() => Tenant)
  @JoinColumn({ name: "tenant_id" })
  tenant: Tenant

  @ManyToMany(() => Extension)
  @JoinTable({
    name: "grupo_membros",
    joinColumn: { name: "grupo_id" },
    inverseJoinColumn: { name: "ramal_id" },
  })
  membros: Extension[]
}
