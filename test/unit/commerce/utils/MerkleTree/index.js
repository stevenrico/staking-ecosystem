import { StandardMerkleTree } from '@openzeppelin/merkle-tree'
import path from 'path'
import { fileURLToPath } from 'url'
import fs from 'fs'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const filename = 'AccessCheckoutMerkleTree'

const values = [
  ['0', '0x7F1d642DbfD62aD4A8fA9810eA619707d09825D0'],
  ['1', '0x5935897A39AFABbedA5a599D38236E7Df151C8b8'],
  ['2', '0x8105660Af15a4eB54Fa0571BC84DFBEC0294A99A'],
  ['3', '0xa78Cac12f68179fd780Ae347F8D4F170FC615D0C'],
  ['4', '0x6f64f6D0d58ACABD288774e993d9caCFa3FC88eE'],
]

async function writeToFile(filename, data) {
  const filePath = path.resolve(__dirname, `./outputs/${filename}.json`)

  await fs.writeFileSync(filePath, JSON.stringify(data))

  console.log(`\n[Merkle Tree]\n- Write to file complete.\n- Location: ${filePath}`)
}

function generateRootAndProofs(values) {
  const tree = StandardMerkleTree.of(values, ['uint256', 'address'])

  const proofs = {}

  for (const [i, v] of tree.entries()) {
    const ticketId = v[0]

    proofs[ticketId] = tree.getProof(i)
  }

  return { root: tree.root, proofs }
}

async function main() {
  const data = generateRootAndProofs(values)

  await writeToFile(filename, data)
}

main()
