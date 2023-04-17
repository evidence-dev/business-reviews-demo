<script>
    import { onMount } from 'svelte'
    import Airtable from 'airtable'
    export let section = undefined;
    export let week_start = undefined;

    let commentary = [];
  
  
    onMount(async () => {
    const res = await getResults()
        commentary = await res
    })

  async function getResults(){
    var base = new Airtable({apiKey: 'keyHqSGvALXEW5mvg'}).base('appF80Ib0QhiPrYxy');

    let results = await base('Commentary').select(
      {
        view: "Grid view"
      }
    ).all().then(function(records) {
      return records.map(function(record) {
        return record.fields
      })
    })
    console.log(results)
    return results
  }
</script>



{#if commentary.filter(d => d.Section === section).filter(d => d.Date === week_start).length > 0}

{#each commentary.filter(d => d.Section === section).filter(d => d.Date === week_start) as comment}

{comment.Commentary}

{/each}

{:else}

No commentary for this week. <a href="/submit-commentary">Add commentary &rarr;</a>

{/if}