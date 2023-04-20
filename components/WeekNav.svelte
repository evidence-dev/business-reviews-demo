<script>
    export let weekNumber = undefined;
    export let year = undefined;
</script>

<span class=week-nav>
    {#if parseInt(weekNumber) > 1}
    <a href="../{((parseInt(weekNumber)-1)+'').padStart(2,'0')}">&larr; Prev. week</a>
    {/if}
    {#if parseInt(weekNumber) < 53 && parseInt(year) > 2020 || parseInt(weekNumber) < 52}
    <a href="../{((parseInt(weekNumber)+1)+'').padStart(2,'0')}">Next week &rarr;</a>
    {/if}
</span>

<style>
    .week-nav {
        display: flex;
        justify-content: space-between;
    }
</style>