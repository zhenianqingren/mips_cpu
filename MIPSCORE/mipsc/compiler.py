imm_dict = {'ori':'001101','andi':'001100','xori':'001110','lui':'001111','addi':'001000','addiu':'001001',
            'slti':'001010','sltiu':'001011'}
spec_dict = {'and':'100100','or':'100101','xor':'100110','nor':'100111','sllv':'000100','srlv':'000110','srav':'000111','sync':'001111',
             'movn':'001011','movz':'001010','mfhi':'010000','mflo':'010010','mthi':'010001','mtlo':'010011',
             'add':'100000','addu':'100001','sub':'100010','subu':'100011','slt':'101010','sltu':'101011',
             'mult':'011000','multu':'011001','div':'011010','divu':'011011','jr':'001000','jalr':'001001',
             'teq':'110100','tge':'110000','tgeu':'110001','tlt':'110010','tltu':'110011','tne':'110110',
             'syscall':'001100'}

spec_sa_dict = {'sll':'000000','srl':'000010','sra':'000011'}
spec2_dict={'clz':'100000','clo':'100001','mul':'000010','madd':'000000','maddu':'000001','msub':'000100','msubu':'000101'}
jmp_dict={'j':'000010','jal':'000011'}
branch_dict={'beq':'000100','bgtz':'000111','blez':'000110','bne':'000101','b':'000100'}
regimm_dict={'bltz':'00000','bltzal':'10000','bgez':'00001','bgezal':'10001','bal':'10001',
             'teqi':'01100','tgei':'01000','tgeiu':'01001','tlti':'01010','tltiu':'01011','tnei':'01110'}
ldst_dict={'lb':'100000','lbu':'100100','lh':'100001','lhu':'100101','lw':'100011','sb':'101000','sh':'101001',
           'sw':'101011','lwl':'100010','lwr':'100110','swl':'101010','swr':'101110','ll':'110000','sc':'111000'}

cp0_dict={'mtc0':'00100','mfc0':'00000'}
eret_dict={'eret':'011000'}

# 格式-> 指令码:二进制码

code=[]
ll=[]
content=[]

def read_input():
    file  = open("C:\\MyApp\\MIPSCPU\\MJH_MIPS\\inst_rom.s")# 读取指定文件的汇编
    for line in file.readlines():
        size = len(line)
        code.append(line[0:size-1])
    return

def pre_process():#根据空格分割
    for line in code:
        ll.append(line.split(' '))

def binary(num,count):#示例binary(13,5) 生成5位二进制数 值为13
    s1 = str(bin(num))
    size = len(s1)
    negative=s1[0]
    begin=1
    if(negative=='-'):
        begin=2
    s1=s1[begin:size]
    s1=s1.replace('b','')
    left = count-len(s1)
    res = left*'0'+s1
    final_res=''
    if(negative=='-'):
        i=0
        for j in range(count-1,-1,-1):
            if(res[j]=='1'):
                i=j
                break
        j=i
        if(i!=0):
            for c in res:
                i=i-1
                if(c=='1'):
                    final_res+='0'
                else:
                    final_res+='1'
                if(i==0):
                    break
        final_res+=res[j:len(res)]
        res=final_res
    return res

def jmp(line):#翻译jmp_dict中的指令
    res=jmp_dict[line[0]]+binary(int(line[1]),26)
    content.append(res)

def branch(line):#翻译branch_dict中的指令
    res=branch_dict[line[0]]
    if(line[0]=='b'):
        res+=10*'0'+binary(int(line[1]),16)
    elif(line[0]=='beq' or line[0]=='bne'):
        res+=binary(int(line[1]),5)+binary(int(line[2]),5)+binary(int(line[3]),16)
    elif(line[0]=='bgtz' or line[0]=='blez'):
        res+=binary(int(line[1]),5)+5*'0'+binary(int(line[2]),16)
    content.append(res)

def regimm(line):#翻译regimm_dict中的指令
    res='000001'
    if(line[0]=='bal'):
        res+=5*'0'+'10001'+binary(int(line[1]),16)
    elif(line[0]=='teqi' or line[0]=='tgei' or line[0]=='tgeiu' or line[0]=='tlti' or line[0]=='tltiu' or line[0]=='tnei'):
        res+=binary(int(line[1]),5)+regimm_dict[line[0]]+binary(int(line[2]),16)
    else:
        res+=binary(int(line[1]),5)+regimm_dict[line[0]]+binary(int(line[2]),16)
    content.append(res)

def cp0(line):#翻译cp0_dict中的指令
    res='010000'+cp0_dict[line[0]]+binary(int(line[1]),5)+binary(int(line[2]),5)+11*'0'
    content.append(res)

def imm(line):#翻译imm_dict中的指令
    res=''
    res+=imm_dict[line[0]]
    if(line[0]!='lui'):
        res+=binary(int(line[2]),5)+binary(int(line[1]),5)+binary(int(line[3]),16)
    else:
        res+=5*'0'+binary(int(line[1]),5)+binary(int(line[2]),16)
    content.append(res)

def ldst(line):#同理
    res=ldst_dict[line[0]]
    t_s=line[2]
    t_offset=t_s[0:t_s.find('(')]
    t_base=t_s[t_s.find('(')+1:len(t_s)-1]
    res+=binary(int(t_base),5)+binary(int(line[1]),5)+binary(int(t_offset),16)
    content.append(res)
def spec(line):#同理
    res="000000"
    if(line[0]=='and' or line[0]=='or' or line[0]=='xor' or line[0]=='nor' or line[0]=='movn' or line[0]=='movz' or
    line[0]=='add' or line[0]=='addu' or line[0]=='sub' or line[0]=='subu' or line[0]=='slt' or line[0]=='sltu'):
        res += binary(int(line[2]), 5) + binary(int(line[3]), 5) + binary(int(line[1]), 5) + 5 * '0' + spec_dict[line[0]]
    elif(line[0]=='mult' or line[0]=='multu' or line[0]=='div' or line[0]=='divu'):
        res+=binary(int(line[1]),5)+binary(int(line[2]),5)+10*'0'+spec_dict[line[0]]
    elif(line[0]=='sllv' or line[0]=='srlv' or line[0]=='srav'):
        res+=binary(int(line[3]),5)+binary(int(line[2]),5)+binary(int(line[1]),5)+5*'0'+spec_dict[line[0]]
    elif(line[0]=='mfhi' or line[0]=='mflo'):
        res+=10*'0'+binary(int(line[1]),5)+5*'0'+spec_dict[line[0]]
    elif(line[0]=='mthi' or line[0]=='mtlo'):
        res+=binary(int(line[1]),5)+15*'0'+spec_dict[line[0]]
    elif(line[0]=='jr'):
        res+=binary(int(line[1]),5)+15*'0'+'001000'
    elif(line[0]=='jalr'):
        if(len(line)==2):
            res+=binary(int(line[1]),5)+5*'0'+5*'1'+5*'0'+'001001'
        else:
            res+=binary(int(line[2]),5)+5*'0'+binary(int(line[1]),5)+5*'0'+'001001'
    elif(line[0]=='sync'):
        res+=20*'0'+'001111'
    elif(line[0]=='teq'or line[0]=='tge' or line[0]=='tgeu' or line[0]=='tlt' or line[0]=='tltu' or line[0]=='tne'):
        res+=binary(int(line[1]),5)+binary(int(line[2]),5)+10*'0'+spec_dict[line[0]]
    elif(line[0]=='syscall'):
        res+=20*'0'+spec_dict[line[0]]
    content.append(res)

def spec2(line):#同理
    res='011100'
    if(line[0]=='clz' or line[0]=='clo'):
        res+=binary(int(line[2]),5)+5*'0'+binary(int(line[1]),5)+5*'0'+spec2_dict[line[0]]
    elif (line[0]=='mul'):
        res+=binary(int(line[2]),5)+binary(int(line[3]),5)+binary(int(line[1]),5)+5*'0'+spec2_dict[line[0]]
    elif (line[0]=='madd' or line[0]=='maddu' or line[0]=='msub' or line[0]=='msubu'):
        res+=binary(int(line[1]),5)+binary(int(line[2]),5)+10*'0'+spec2_dict[line[0]]
    content.append(res)


def spec_sa(line):#同理
    res=11*'0'
    res+=binary(int(line[2]),5)+binary(int(line[1]),5)+binary(int(line[3]),5)+spec_sa_dict[line[0]]
    content.append(res)

def eret(line):#同理
    res='010000'+'1'+19*'0'+'011000'
    content.append(res)

def compile():#主程序 根据程序码交给相应的处理程序
    for line in ll:
        if imm_dict.get(line[0])!=None:
            imm(line)
        elif spec_dict.get(line[0])!=None:
            spec(line)
        elif spec_sa_dict.get(line[0])!=None:
            spec_sa(line)
        elif spec2_dict.get(line[0])!=None:
            spec2(line)
        elif jmp_dict.get(line[0])!=None:
            jmp(line)
        elif branch_dict.get(line[0])!=None:
            branch(line)
        elif regimm_dict.get(line[0])!=None:
            regimm(line)
        elif ldst_dict.get(line[0])!=None:
            ldst(line)
        elif cp0_dict.get(line[0])!=None:
            cp0(line)
        elif eret_dict.get(line[0])!=None:
            eret(line)

def output():#输出到某个文件
    file=open("C:\\MyApp\\MIPSCPU\\MJH_MIPS\\inst_rom.data",'w')
    for line in content:
        line+='\n'
        file.write(line)
    file.close()

read_input()
pre_process()
compile()
output()

