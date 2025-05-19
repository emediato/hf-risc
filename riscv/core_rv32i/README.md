## 
RISC-V é uma evoluçao do MIPS

## reg bank
banco de registradores de um processador
MIPS - write_reg nem sempre é 0

## pipeline

<img width="964" alt="image" src="https://github.com/user-attachments/assets/3fd1bf19-2a72-4a78-850e-d75cb11c6bc5" />


## 3rd stage datapath.vhd
	alu_src1 <= read_data1 when alu_src1_ctl_r = '0' else pc_last2;

<img width="674" alt="image" src="https://github.com/user-attachments/assets/5d5af65c-bc09-442e-b472-cfb320c71e79" />
