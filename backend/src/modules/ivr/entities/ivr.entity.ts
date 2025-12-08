import { Entity, Column, ManyToOne, JoinColumn, OneToMany } from "typeorm"
import { BaseEntity } from "../../../common/entities/base.entity"
import { Tenant } from "../../tenants/entities/tenant.entity"
import { IvrOption } from "./ivr-option.entity"

@Entity("uras")
export class Ivr extends BaseEntity {
  @Column({ name: "tenant_id" })
  tenantId: number

  @Column()
  nome: string

  @Column({ nullable: true })
  descricao: string

  @Column({ name: "audio_boas_vindas", nullable: true })
  audioBoasVindas: string

  @Column({ name: "audio_invalido", nullable: true })
  audioInvalido: string

  @Column({ name: "tentativas_maximas", default: 3 })
  tentativasMaximas: number

  @Column({ name: "timeout_digito", default: 5 })
  timeoutDigito: number

  @Column({ default: true })
  ativo: boolean

  @ManyToOne(() => Tenant)
  @JoinColumn({ name: "tenant_id" })
  tenant: Tenant

  @OneToMany(
    () => IvrOption,
    (option) => option.ivr,
  )
  opcoes: IvrOption[]
}
