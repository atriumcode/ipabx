import { Entity, Column, ManyToOne, JoinColumn } from "typeorm"
import { BaseEntity } from "../../../common/entities/base.entity"
import { Tenant } from "../../tenants/entities/tenant.entity"

@Entity("gravacoes")
export class Recording extends BaseEntity {
  @Column({ name: "tenant_id" })
  tenantId: number

  @Column()
  nome: string

  @Column({ name: "caminho_arquivo" })
  caminhoArquivo: string

  @Column({ type: "integer", nullable: true })
  duracao: number

  @Column({ nullable: true })
  formato: string

  @Column({ name: "tamanho_bytes", type: "bigint", nullable: true })
  tamanhoBytes: number

  @Column({ nullable: true })
  descricao: string

  @ManyToOne(() => Tenant)
  @JoinColumn({ name: "tenant_id" })
  tenant: Tenant
}
