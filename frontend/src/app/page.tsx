"use client";

import PropertiesGrid from './_components/PropertiesGrid'
import { useRouter } from 'next/navigation'

export default function Home() {
  const router = useRouter();

  return <div>
    <div className="flex flex-row justify-end mb-2">
      <button
        className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
        onClick={() => router.push('/property')}
      >Add +</button>
    </div>
    <PropertiesGrid />
  </div>
}
