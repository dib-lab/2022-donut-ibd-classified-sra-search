rule read_csv:
    input:
        path="ibd_full.csv"
    output:
        
    shell: '''
        print(Run)
    '''
