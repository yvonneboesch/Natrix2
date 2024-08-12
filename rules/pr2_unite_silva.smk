
if config["classify"]["database"] == "pr2":
    rule download_pr2:
        output:
            expand(["database/pr2db.{pr2_db_version}.fasta", "database/pr2db.{pr2_db_version}.tax"], pr2_db_version=config["database_version"]["pr2"])
        params:
            db_version=config["database_version"]["pr2"]
        shell:
            """
                wget -P ./ --progress=bar https://github.com/pr2database/pr2database/releases/download/v{params.db_version}/pr2_version_{params.db_version}_SSU_mothur.fasta.gz;
                wget -P ./ --progress=bar https://github.com/pr2database/pr2database/releases/download/v{params.db_version}/pr2_version_{params.db_version}_SSU_mothur.tax.gz;
                gunzip -c ./pr2_version_{params.db_version}_SSU_mothur.fasta.gz > database/pr2db.{params.db_version}.fasta;
                gunzip -c ./pr2_version_{params.db_version}_SSU_mothur.tax.gz > database/pr2db.{params.db_version}.tax;
                rm ./pr2_version_{params.db_version}_SSU_mothur.tax.gz ./pr2_version_{params.db_version}_SSU_mothur.fasta.gz;
            """

elif config["classify"]["database"] == "unite":
    rule download_unite:
        output:
            "database/unite_v10.fasta",
            "database/unite_v10.tax" # no version for download available, needs to be changed here not in config
        shell:
            """
                wget -P ./ --progress=bar  -O sh_mothur_release_2024-04-04.tgz --progress=bar https://s3.hpc.ut.ee/plutof-public/original/10220f9f-17c8-4a2f-aada-1f852f50c0f7.tgz;
                mkdir -p sh_mothur_release_2024-04-04;
                tar -xvf sh_mothur_release_2024-04-04.tgz -C sh_mothur_release_2024-04-04;
                mv sh_mothur_release_2024-04-04/UNITEv10_sh_99.tax database/unite_v10.tax;
                mv sh_mothur_release_2024-04-04/UNITEv10_sh_99.fasta {output[0]};
                rm -rf sh_mothur_release_2024-04-04;
                rm sh_mothur_release_2024-04-04.tgz;
            """

elif config["classify"]["database"] == "silva":
        rule download_silva:
            output:
                expand(["database/silva_db.{silva_db_version}.fasta", "database/silva_db.{silva_db_version}.tax.temp"], silva_db_version=config["database_version"]["silva"])
            params:
                db_version=config["database_version"]["silva"]
            shell:
                """
                wget -P ./ --progress=bar -O database/silva_{params.db_version}.fasta.gz https://www.arb-silva.de/fileadmin/silva_databases/current/Exports/SILVA_{params.db_version}_SSURef_tax_silva.fasta.gz;
                gunzip -c database/silva_{params.db_version}.fasta.gz > database/silva_db.{params.db_version}.fasta;
                wget -P ./ --progress=bar -O database/silva_{params.db_version}.tax.gz https://www.arb-silva.de/fileadmin/silva_databases/current/Exports/taxonomy/taxmap_slv_ssu_ref_{params.db_version}.txt.gz
                gunzip -c database/silva_{params.db_version}.tax.gz > database/silva_db.{params.db_version}.tax.temp;
                """

        rule edit_silva:
           input:
              expand("database/silva_db.{silva_db_version}.tax.temp", silva_db_version=config["database_version"]["silva"])
           output:
              expand("database/silva_db.{silva_db_version}.tax", silva_db_version=config["database_version"]["silva"])
           conda:
              "../envs/blast.yaml"
           script:
              "../scripts/edit_silva_mothur.py"
