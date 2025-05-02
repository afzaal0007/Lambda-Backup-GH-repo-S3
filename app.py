import os
import subprocess
import tarfile
import boto3
import datetime
import shutil

def lambda_handler(event, context):
    GITHUB_TOKEN = os.environ['GITHUB_TOKEN']
    S3_BUCKET = os.environ['S3_BUCKET']
    REPO_LIST_KEY = os.environ['REPO_LIST_KEY']
    TMP_DIR = "/tmp"
    TIMESTAMP = datetime.datetime.utcnow().strftime('%Y%m%d%H%M%S')

    # Download repos.txt from S3
    s3 = boto3.client('s3')
    local_repo_list_path = os.path.join(TMP_DIR, "repos.txt")
    s3.download_file(S3_BUCKET, REPO_LIST_KEY, local_repo_list_path)

    # Read repo URLs
    with open(local_repo_list_path, 'r') as f:
        repo_urls = [line.strip() for line in f if line.strip()]

    for repo_url in repo_urls:
        repo_name = repo_url.split("/")[-1].replace(".git", "")
        repo_path = os.path.join(TMP_DIR, f"{repo_name}.git")
        archive_path = os.path.join(TMP_DIR, f"{repo_name}-{TIMESTAMP}.tar.gz")
        repo_url_auth = f"https://{GITHUB_TOKEN}@{repo_url}"

        try:
            subprocess.run(["git", "clone", "--mirror", repo_url_auth, repo_path], check=True)
            with tarfile.open(archive_path, "w:gz") as tar:
                tar.add(repo_path, arcname=os.path.basename(repo_path))
            s3.upload_file(archive_path, S3_BUCKET, f"github-backups/{repo_name}/{repo_name}-{TIMESTAMP}.tar.gz")
            print(f"✔️ {repo_name} backup uploaded.")
        except Exception as e:
            print(f"❌ Failed to back up {repo_url}: {e}")
        finally:
            shutil.rmtree(repo_path, ignore_errors=True)
            if os.path.exists(archive_path):
                os.remove(archive_path)

    return {
        'statusCode': 200,
        'body': f"Backup completed for {len(repo_urls)} repositories."
    }
