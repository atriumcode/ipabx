import { Entity, Column, ManyToOne, JoinColumn } from "typeorm"
import { BaseEntity } from "../../../common/entities/base.entity"
import { Ivr } from "./ivr.entity"

@Entity("ura_opcoes")
export class IvrOption extends BaseEntity {
  @Column({ name: "ura_id" })
  uraId: number

  @Column()
  digito: string

  @Column({ name: "tipo_acao" })
  tipoAcao: string

  @Column({ name: "destino_id", nullable: true })
  destinoId: number

  @Column({ nullable: true })
  descricao: string

  @ManyToOne(
    () => Ivr,
    (ivr) => ivr.opcoes,
  )
  @JoinColumn({ name: "ura_id" })
  ivr: Ivr
}
